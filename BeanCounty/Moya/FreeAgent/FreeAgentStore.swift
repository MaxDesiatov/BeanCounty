//
//  FreeAgentStore.swift
//  BeanCounty
//
//  Created by Max Desiatov on 29/03/2020.
//  Copyright © 2020 Digital Signal Limited. All rights reserved.
//

import Alamofire
import Combine
import Foundation
import KeychainAccess
import Moya
import OAuthSwift
import OAuthSwiftAlamofire

private let consumerKeyKey = "freeAgentConsumerKey"
private let consumerSecretKey = "freeAgentConsumerSecret"
private let credentialKey = "freeAgentCredential"

final class FreeAgentStore: ObservableObject {
  @Published var consumerKey: String
  @Published var consumerSecret: String
  @Published var isAuthenticated = false

  private let keychain: Keychain
  private var subscriptions = Set<AnyCancellable>()

  private var oauth: OAuth2Swift?
  private var provider: MoyaProvider<FreeAgent>?

  /// `nil` represents `loading` state
  @Published private(set) var bankAccounts: MoyaResult<[FABankAccount]>?

  /// Index of a currently selected bank account
  @Published var selectedBankAccountIndex = 3

  @Published private(set) var transactions: MoyaResult<[FATransaction]>?

  init() {
    keychain = Keychain(service: keychainService)
    consumerKey = keychain[consumerKeyKey] ?? ""
    consumerSecret = keychain[consumerSecretKey] ?? ""

    $consumerKey
      .write(as: consumerKeyKey, to: keychain)
      .store(in: &subscriptions)

    $consumerSecret
      .write(as: consumerSecretKey, to: keychain)
      .store(in: &subscriptions)

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .faDate

    $bankAccounts
      .combineLatest($selectedBankAccountIndex)
      .compactMap { accountsResult, index in try? accountsResult?.map { $0[index] }.get() }
      .flatMap { [weak self] bankAccount -> AnyPublisher<MoyaResult<[FATransaction]>, Never> in
        guard let provider = self?.provider else { return Empty().eraseToAnyPublisher() }

        return provider.requestPublisher(.transactions(bankAccount))
          .map(FATransactions.self, using: decoder)
          .map(\.bankTransactions)
          .map { Result.success($0) }
          .catch { Just(.failure($0)) }
          .eraseToAnyPublisher()
      }
      .map { $0 }
      .assign(to: \.transactions, on: self)
      .store(in: &subscriptions)

    let credentialDecoder = JSONDecoder()

    guard
      !consumerKey.isEmpty && !consumerSecret.isEmpty,
      let encodedCredential = keychain[credentialKey],
      let data = encodedCredential.data(using: .utf8),
      let credential = try? credentialDecoder.decode(OAuthSwiftCredential.self, from: data)
    else { return }

    setupOAuth()
    oauth?.client = OAuthSwiftClient(credential: credential)
    setupProvider()
  }

  private func setupOAuth() {
    oauth = OAuth2Swift(
      consumerKey: consumerKey,
      consumerSecret: consumerSecret,
      authorizeUrl: "https://api.freeagent.com/v2/approve_app",
      accessTokenUrl: "https://api.freeagent.com/v2/token_endpoint",
      responseType: "code"
    )
  }

  private func setupProvider() {
    let session = Session(interceptor: oauth!.requestInterceptor)

    provider = MoyaProvider<FreeAgent>(session: session, plugins: [
      NetworkLoggerPlugin(configuration: .init(logOptions: [
        .errorResponseBody,
        .formatRequestAscURL,
      ])),
    ])

    isAuthenticated = true

    provider?.requestPublisher(.bankAccounts)
      .map(FABankAccounts.self)
      .map(\.bankAccounts)
      .map(Result.success)
      .catch { Just(.failure($0)) }
      // convert from non-optional to optional
      .map { $0 }
      .assign(to: \.bankAccounts, on: self)
      .store(in: &subscriptions)
  }

  func authenticate() {
    precondition(!consumerKey.isEmpty)
    precondition(!consumerSecret.isEmpty)

    setupOAuth()

    oauth?.authorize(with: "bean-county://oauth-callback/freeagent")
      .encode(encoder: JSONEncoder())
      .compactMap { String(data: $0, encoding: .utf8) }
      // FIXME: error handling
      .assertNoFailure()
      .handleEvents(receiveOutput: { [weak self] _ in self?.setupProvider() })
      .assign(to: \.[credentialKey], on: keychain)
      .store(in: &subscriptions)
  }

  func signOut() {
    bankAccounts = nil
    keychain[credentialKey] = nil
    isAuthenticated = false
  }

  func upload(_ transactions: [TWTransaction]) -> ResultPublisher<()> {
    // swiftlint:disable force_try
    let bankAccount = try! bankAccounts!.get()[selectedBankAccountIndex]
    let statement = FAStatement(
      statement: transactions.flatMap { transaction -> [FAStatement.Item] in
        let item = FAStatement.Item(
          datedOn: transaction.date,
          amount: transaction.amount.value + transaction.totalFees.value,
          description: "Transfer \(transaction.amount.value > 0 ? "to" : "from") TransferWise"
        )

        guard transaction.totalFees.value > 0 else { return [item] }

        return [
          item,
          .init(
            datedOn: transaction.date,
            amount: -transaction.totalFees.value,
            description: "TransferWise Fee"
          ),
        ]
      }
    )

    return try! provider!.requestPublisher(.upload(bankAccount, statement))
      .map { _ in
        Result.success(())
      }
      .catch {
        Just(.failure($0))
      }
      .eraseToAnyPublisher()
  }
}

final class Runner<T>: ObservableObject {
  enum State {
    case initial
    case running
    case success(T)
    case failure(MoyaError)
  }

  let publisher: ResultPublisher<T>

  var subscription: AnyCancellable?

  @Published var state = State.initial

  init(_ publisher: ResultPublisher<T>) {
    self.publisher = publisher
  }

  func run() {
    state = .running
    subscription = publisher
      .map {
        switch $0 {
        case let .success(value):
          return .success(value)
        case let .failure(error):
          return .failure(error)
        }
      }.assign(to: \.state, on: self)
  }
}

extension JSONDecoder.DateDecodingStrategy {
  static var faDate: Self {
    .custom {
      let container = try $0.singleValueContainer()
      let string = try container.decode(String.self)
      let dateFormatter = ISO8601DateFormatter()
      dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]

      guard let date = dateFormatter.date(from: string) else {
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "can't decode date")
      }

      return date
    }
  }
}

extension JSONEncoder.DateEncodingStrategy {
  static var faDate: Self {
    .custom { date, encoder in
      var container = encoder.singleValueContainer()

      let dateFormatter = ISO8601DateFormatter()
      dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]

      let string = dateFormatter.string(from: date)
      try container.encode(string)
    }
  }
}

extension OAuth2Swift {
  func authorize(with callbackURL: String) -> Future<OAuthSwiftCredential, OAuthSwiftError> {
    Future { promise in
      self.authorize(withCallbackURL: callbackURL, scope: "", state: "FreeAgent") {
        promise($0.map { $0.0 })
      }
    }
  }
}

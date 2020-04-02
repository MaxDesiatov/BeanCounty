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

    $bankAccounts
      .combineLatest($selectedBankAccountIndex)
      .compactMap { accountsResult, index in try? accountsResult?.map { $0[index] }.get() }
      .flatMap { [weak self] bankAccount -> AnyPublisher<String, Never> in
        guard let provider = self?.provider else { return Empty().eraseToAnyPublisher() }

        return provider.requestPublisher(.transactions(bankAccount))
          .mapString()
          .catch { Just($0.localizedDescription) }
          .eraseToAnyPublisher()
      }.sink {
        print($0)
      }.store(in: &subscriptions)

    let decoder = JSONDecoder()

    guard
      !consumerKey.isEmpty && !consumerSecret.isEmpty,
      let encodedCredential = keychain[credentialKey],
      let data = encodedCredential.data(using: .utf8),
      let credential = try? decoder.decode(OAuthSwiftCredential.self, from: data)
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

    provider = MoyaProvider<FreeAgent>(session: session)

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

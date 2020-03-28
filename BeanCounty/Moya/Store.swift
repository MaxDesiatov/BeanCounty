//
//  Store.swift
//  BeanCounty
//
//  Created by Max Desiatov on 26/12/2019.
//  Copyright © 2019 Digital Signal Limited. All rights reserved.
//

import Combine
import Foundation
import KeychainAccess
import Moya

typealias ResultPublisher<Output> = AnyPublisher<Result<Output, MoyaError>, Never>

private let transferWiseTokenKey = "transferWiseToken"

final class Store: ObservableObject {
  private lazy var transferWiseProvider = MoyaProvider<TransferWise>(plugins: [
    AccessTokenPlugin { [weak self] _ in self?.transferWiseToken ?? "" },
  ])

  @Published var transferWiseToken: String

  /// Index of a currently selected profile
  @Published private(set) var selectedProfileIndex = 1

  /// `nil` represents `loading` state
  @Published private(set) var availableProfiles: Result<[Profile], MoyaError>?

  private let keychain: Keychain
  private var subscriptions = Set<AnyCancellable>()

  init(availableProfiles: Result<[Profile], MoyaError>? = nil) {
    self.availableProfiles = availableProfiles
    keychain = Keychain(service: "com.dsignal.BeanCounty")
    transferWiseToken = keychain[transferWiseTokenKey] ?? ""

    $transferWiseToken
      // stop rewriting the token just after it's loaded here with `dropFirst`
      .dropFirst()
      // convert from non-optional to optional
      .map { $0 }
      // store updated token in the keychain
      .assign(to: \.[transferWiseTokenKey], on: keychain)
      .store(in: &subscriptions)

    profiles
      // convert from non-optional to optional
      .map { $0 }
      .assign(to: \.availableProfiles, on: self)
      .store(in: &subscriptions)
  }

  private lazy var profiles =
    $transferWiseToken
      .flatMap { _ in
        self.transferWiseProvider.requestPublisher(
          .profiles
        )
        .map([Profile].self)
        .map(Result<[Profile], MoyaError>.success)
        .catch {
          Just(.failure($0))
        }
      }.eraseToAnyPublisher()

  private(set) lazy var selectedProfile =
    $availableProfiles
      .compactMap { $0 }
      .combineLatest($selectedProfileIndex)
      .map { profiles, index in
        profiles.map { $0[index] }
      }.eraseToAnyPublisher()

  private(set) lazy var accounts =
    selectedProfile
      .flatMap {
        $0.publisher
          .flatMap {
            self.transferWiseProvider.requestPublisher(
              .accounts(profileID: $0.id)
            )
            .map([Account].self)
          }
          .map(Result.success)
          .catch { Just(.failure($0)) }
      }
      .eraseToAnyPublisher()

  func statement(accountID: Int, currency: String) -> ResultPublisher<[Transaction]> {
    selectedProfile
      .flatMap {
        $0.publisher
          .flatMap {
            self.transferWiseProvider.requestPublisher(.statement(
              profileID: $0.id,
              accountID: accountID,
              currency: currency,
              start: Date() - 60 * 60 * 24 * 365,
              end: Date()
            ))
              .map(Statement.self)
              .map(\.transactions)
          }
          .map(Result.success)
          .catch { Just(.failure($0)) }
      }
      .eraseToAnyPublisher()
  }
}

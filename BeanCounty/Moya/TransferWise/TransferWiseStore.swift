//
//  TransferWiseStore.swift
//  BeanCounty
//
//  Created by Max Desiatov on 26/12/2019.
//  Copyright © 2019 Digital Signal Limited. All rights reserved.
//

import Combine
import Foundation
import KeychainAccess
import Moya

typealias ResultPublisher<Output> = AnyPublisher<MoyaResult<Output>, Never>

private let transferWiseTokenKey = "transferWiseToken"

final class TransferWiseStore: ObservableObject {
  private lazy var transferWiseProvider = MoyaProvider<TransferWise>(plugins: [
    AccessTokenPlugin { [weak self] _ in self?.token ?? "" },
  ])

  @Published var token: String

  /// Index of a currently selected profile
  @Published var selectedProfileIndex = 1

  /// `nil` represents `loading` state
  @Published private(set) var availableProfiles: MoyaResult<[Profile]>?

  private let keychain: Keychain
  private var subscriptions = Set<AnyCancellable>()

  init(availableProfiles: Result<[Profile], MoyaError>? = nil) {
    self.availableProfiles = availableProfiles
    keychain = Keychain(service: keychainService)
    token = keychain[transferWiseTokenKey] ?? ""

    $token
      .write(as: transferWiseTokenKey, to: keychain)
      .store(in: &subscriptions)

    profiles
      // convert from non-optional to optional
      .map { $0 }
      .assign(to: \.availableProfiles, on: self)
      .store(in: &subscriptions)
  }

  private lazy var profiles =
    $token
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

  func statement(accountID: Int, currency: String) -> ResultPublisher<[TWTransaction]> {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .twISODate

    return selectedProfile
      .flatMap {
        $0.publisher
          .flatMap {
            self.transferWiseProvider.requestPublisher(.statement(
              profileID: $0.id,
              accountID: accountID,
              currency: currency,
              start: Date() - 60 * 60 * 24 * 310,
              end: Date()
            ))
              .map(Statement.self, using: decoder)
              .map(\.transactions)
          }
          .map(Result.success)
          .catch { Just(.failure($0)) }
      }
      .eraseToAnyPublisher()
  }
}

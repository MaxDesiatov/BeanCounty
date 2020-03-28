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

private let transferWiseTokenKey = "transferWiseToken"

enum ResponseError: Error {
  case noArrayElements
}

final class Store: ObservableObject {
  private lazy var transferWiseProvider = MoyaProvider<TransferWise>(plugins: [
    AccessTokenPlugin { [weak self] _ in self?.transferWiseToken ?? "" },
  ])

  @Published var transferWiseToken: String

  /// Index of a currently selected profile
  @Published private(set) var selectedProfileIndex = 0

  /// `nil` represents `loading` state
  @Published private(set) var availableProfiles: Result<[Profile], Error>?

  private let keychain: Keychain
  private var subscriptions = Set<AnyCancellable>()

  init(availableProfiles: Result<[Profile], Error>? = nil) {
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

  private lazy var profiles = $transferWiseToken
    .flatMap { _ in
      self.transferWiseProvider.requestPublisher(
        .profiles
      )
      .map([Profile].self)
      .map(Result<[Profile], Error>.success)
      .catch { Just(.failure($0)) }
    }.eraseToAnyPublisher()

  private(set) lazy var selectedProfile = $availableProfiles
    .compactMap { $0 }
    .combineLatest($selectedProfileIndex)
    .map { profiles, index in
      profiles.map { $0[index] }
    }.eraseToAnyPublisher()

  private(set) lazy var accounts = selectedProfile
    .flatMap {
      $0.publisher
        .flatMap {
          self.transferWiseProvider.requestPublisher(
            .accounts(profileID: $0.id)
          )
          .map([Account].self)
          .mapError { $0 as Error }
        }
        .map(Result<[Account], Error>.success)
        .catch { Just(.failure($0)) }
    }
    .eraseToAnyPublisher()
}

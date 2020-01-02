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

struct Profile: Codable {
  let id: Int
  let type: String
  let details: Details
}

struct Details: Codable {
  let firstName, lastName, dateOfBirth, phoneNumber: String?
  let primaryAddress: Int
  let name, registrationNumber: String?
  let companyType, companyRole, descriptionOfBusiness: String?
  let webpage: String?
  let businessCategory, businessSubCategory: String?
}

struct Account: Codable, Identifiable, Hashable {
  enum CodingKeys: String, CodingKey {
    case id
    case profileID = "profileId"
    case recipientID = "recipientId"
    case creationTime, modificationTime, active, eligible, balances
  }

  let id, profileID, recipientID: Int
  let creationTime, modificationTime: String
  let active, eligible: Bool
  let balances: [Balance]
}

struct Balance: Codable, Hashable {
  let balanceType, currency: String
  let amount, reservedAmount: Amount
}

struct Amount: Codable, Hashable {
  let value: Decimal
  let currency: String
}

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
  @Published var selectedProfileIndex = 0

  @Published var availableProfiles: Result<[Profile], Error>?

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
      .map { $0 }
      .assign(to: \.availableProfiles, on: self)
      .store(in: &subscriptions)
  }

  private(set) lazy var profiles = $transferWiseToken
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

  private(set) lazy var accounts = $transferWiseToken
    .setFailureType(to: Error.self)
    .combineLatest(
      // unwrap `Result` type to make processing easier
      selectedProfile.tryMap { try $0.get() }
    )
    .flatMap { _, profile in
      self.transferWiseProvider.requestPublisher(
        .accounts(profileID: profile.id)
      )
      .map([Account].self)
      .mapError { $0 as Error }
    }
    .map(Result<[Account], Error>.success)
    .catch { Just(.failure($0)) }
    .eraseToAnyPublisher()
}

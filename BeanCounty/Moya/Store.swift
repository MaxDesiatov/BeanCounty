//
//  Store.swift
//  BeanCounty
//
//  Created by Max Desiatov on 26/12/2019.
//  Copyright © 2019 Digital Signal Limited. All rights reserved.
//

import Combine
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

struct Account: Codable {
  let id, profileID, recipientID: Int
  let creationTime, modificationTime: String
  let active, eligible: Bool
  let balances: [Balance]

  enum CodingKeys: String, CodingKey {
    case id
    case profileID
    case recipientID
    case creationTime, modificationTime, active, eligible, balances
  }
}

struct Balance: Codable {
  let balanceType, currency: String
  let amount, reservedAmount: Amount
}

struct Amount: Codable {
  let value: Double
  let currency: String
}

private let transferWiseTokenKey = "transferWiseToken"

final class Store: ObservableObject {
  private lazy var transfwerWiseProvider = MoyaProvider<TransferWise>(plugins: [
    AccessTokenPlugin { [weak self] _ in self?.transferWiseToken ?? "" },
  ])

  @Published var transferWiseToken: String

  private let keychain: Keychain
  private var subscriptions = Set<AnyCancellable>()

  init() {
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
  }

  lazy var profileType = $transferWiseToken.flatMap { _ in
    self.transfwerWiseProvider.requestPublisher(
      .profiles
    )
    .map([Profile].self)
    .map(\.[0].type)
    .catch { _ in
      Just("request failed")
    }
  }
}

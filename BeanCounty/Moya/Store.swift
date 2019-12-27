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

enum ResponseError: Error {
  case noArrayElements
}

enum ResponseState<T> {
  case loading
  case failed(Error)
  case loaded(T)
}

final class Store: ObservableObject {
  private lazy var transferWiseProvider = MoyaProvider<TransferWise>(plugins: [
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

  private(set) lazy var profileType = $transferWiseToken.flatMap { _ in
    self.transferWiseProvider.requestPublisher(
      .profiles
    )
    .map([Profile].self)
    .tryMap {
      guard let type = $0.first?.type else {
        throw ResponseError.noArrayElements
      }

      return ResponseState.loaded(type)
    }
    .catch { Just(ResponseState<String>.failed($0)) }
  }

  private(set) lazy var accounts = $transferWiseToken.flatMap { _ in
    self.transferWiseProvider.requestPublisher(
      .profiles
    )
    .map([Account].self)
    .map(\.[0].creationTime)
    .catch { _ in
      Just("request failed")
    }
  }
}

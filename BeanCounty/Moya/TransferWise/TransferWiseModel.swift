//
//  Model.swift
//  BeanCounty
//
//  Created by Max Desiatov on 05/01/2020.
//  Copyright © 2020 Digital Signal Limited. All rights reserved.
//

import Foundation

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

struct Balance: Codable {
  let balanceType, currency: String
  let amount: TWAmount
}

extension Balance: Identifiable {
  var id: String { currency }
}

struct TWAmount: Codable {
  let value: Decimal
  let currency: String
}

private func format(_ value: Decimal, currencyCode: String) -> String? {
  let result = NumberFormatter()
  result.numberStyle = .currency
  result.currencyCode = currencyCode
  return result.string(from: value as NSNumber)
}

extension TWAmount: CustomStringConvertible {
  var description: String { format(value, currencyCode: currency) ?? "" }
}

struct Statement: Codable {
  let accountHolder: AccountHolder
  let issuer: Issuer
  let transactions: [TWTransaction]
  let endOfStatementBalance: TWAmount
  let query: Query
}

struct AccountHolder: Codable {
  let type: String
  let address: Address
  let firstName: String?
  let lastName: String?
}

struct Address: Codable {
  let addressFirstLine, city, postCode: String
  let stateCode: String?
  let countryName: String
}

struct Issuer: Codable {
  let name, firstLine, city, postCode: String
  let stateCode: String?
  let country: String
}

struct Query: Codable {
  let intervalStart: String
  let intervalEnd: String
  let currency: String
  let accountID: Int?
}

struct TWTransaction: Codable {
  let type: String
  let date: Date
  let amount, totalFees: TWAmount
  let details: TransactionDetails
  let exchangeDetails: ExchangeDetails?
  let runningBalance: TWAmount
  let referenceNumber: String
}

extension TWTransaction: Identifiable {
  var id: String { referenceNumber }
}

extension JSONDecoder.DateDecodingStrategy {
  static var twISODate: Self {
    .custom {
      let container = try $0.singleValueContainer()
      let string = try container.decode(String.self)
      let dateFormatter = ISO8601DateFormatter()
      dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

      guard let date = dateFormatter.date(from: string) else {
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "can't decode date")
      }

      return date
    }
  }
}

struct TransactionDetails: Codable {
  let type: String
  let detailsDescription: String?
  let amount: TWAmount?
  let category: String?
  let merchant: Merchant?
  let senderName, senderAccount, paymentReference: String?
  let sourceAmount, targetAmount, fee: TWAmount?
  let rate: Decimal?
}

struct Merchant: Codable {
  let name: String
  let postCode, city, state, country: String
  let category: String
}

struct ExchangeDetails: Codable {
  let forAmount: TWAmount?
}

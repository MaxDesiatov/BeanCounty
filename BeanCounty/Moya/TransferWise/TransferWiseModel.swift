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
  let amount: Amount
}

extension Balance: Identifiable {
  var id: String { currency }
}

struct Amount: Codable {
  let value: Decimal
  let currency: String
}

private func format(_ value: Decimal, currencyCode: String) -> String? {
  let result = NumberFormatter()
  result.numberStyle = .currency
  result.currencyCode = currencyCode
  return result.string(from: value as NSNumber)
}

extension Amount: CustomStringConvertible {
  var description: String { format(value, currencyCode: currency) ?? "" }
}

struct Statement: Codable {
  let accountHolder: AccountHolder
  let issuer: Issuer
  let transactions: [TWTransaction]
  let endOfStatementBalance: Amount
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
  let date: ISODate
  let amount, totalFees: Amount
  let details: TransactionDetails
  let exchangeDetails: ExchangeDetails?
  let runningBalance: Amount
  let referenceNumber: String
}

extension TWTransaction: Identifiable {
  var id: String { referenceNumber }
}

struct ISODate: Codable {
  let value: Date

  init(value: Date) {
    self.value = value
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    guard let date = dateFormatter.date(from: string) else {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "can't decode date")
    }

    value = date
  }
}

struct TransactionDetails: Codable {
  let type: String
  let detailsDescription: String?
  let amount: Amount?
  let category: String?
  let merchant: Merchant?
  let senderName, senderAccount, paymentReference: String?
  let sourceAmount, targetAmount, fee: Amount?
  let rate: Decimal?
}

struct Merchant: Codable {
  let name: String
  let postCode, city, state, country: String
  let category: String
}

struct ExchangeDetails: Codable {
  let forAmount: Amount?
}

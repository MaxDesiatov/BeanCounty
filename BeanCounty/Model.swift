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

struct Statement: Codable {
  let accountHolder: AccountHolder
  let issuer: Issuer
  let transactions: [Transaction]
  let endOfStatementBalance: EndOfStatementBalance
  let query: Query
}

struct AccountHolder: Codable {
  let type: String
  let address: Address
  let firstName, lastName: String
}

struct Address: Codable {
  let addressFirstLine, city, postCode, stateCode: String
  let countryName: String
}

// MARK: - EndOfStatementBalance

struct EndOfStatementBalance: Codable {
  let value: Double
  let currency: String
}

struct Issuer: Codable {
  let name, firstLine, city, postCode: String
  let stateCode, country: String
}

struct Query: Codable {
  let intervalStart: Date
  let intervalEnd: String
  let currency: String
  let accountID: Int

  enum CodingKeys: String, CodingKey {
    case intervalStart, intervalEnd, currency
    case accountID
  }
}

struct Transaction: Codable {
  let type, date: String
  let amount, totalFees: EndOfStatementBalance
  let details: TransactionDetails
  let exchangeDetails: ExchangeDetails?
  let runningBalance: EndOfStatementBalance
  let referenceNumber: String
}

struct TransactionDetails: Codable {
  let type, detailsDescription: String
  let amount: EndOfStatementBalance?
  let category: String?
  let merchant: Merchant?
  let senderName, senderAccount, paymentReference: String?
  let sourceAmount, targetAmount, fee: EndOfStatementBalance?
  let rate: Double?

  enum CodingKeys: String, CodingKey {
    case type
    case detailsDescription
    case amount
    case category
    case merchant
    case senderName
    case senderAccount
    case paymentReference
    case sourceAmount
    case targetAmount
    case fee
    case rate
  }
}

struct Merchant: Codable {
  let name: String
  let postCode, city, state, country: String
  let category: String
}

struct ExchangeDetails: Codable {
  let forAmount: EndOfStatementBalance
}

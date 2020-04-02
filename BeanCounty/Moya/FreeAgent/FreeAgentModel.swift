//
//  FreeAgentModel.swift
//  BeanCounty
//
//  Created by Max Desiatov on 01/04/2020.
//  Copyright © 2020 Digital Signal Limited. All rights reserved.
//

import Foundation

struct FreeAgentBankAccounts: Codable {
  let bankAccounts: [BankAccount]

  enum CodingKeys: String, CodingKey {
    case bankAccounts = "bank_accounts"
  }
}

struct BankAccount: Codable {
  let url, openingBalance: String
  let bankName: String?
  let type, name: String
  let isPersonal, isPrimary: Bool
  let status, currency, currentBalance: String
  let markedForReviewCount: Int
  let totalCount: Int
  let unexplainedTransactionCount: Int
  let manuallyAddedTransactionCount: Int
  let accountNumber, sortCode: String?
  let bankCode, latestActivityDate, updatedAt, createdAt: String
  let email: String?

  enum CodingKeys: String, CodingKey {
    case url
    case openingBalance = "opening_balance"
    case bankName = "bank_name"
    case type, name
    case isPersonal = "is_personal"
    case isPrimary = "is_primary"
    case status, currency
    case currentBalance = "current_balance"
    case markedForReviewCount = "marked_for_review_count"
    case totalCount = "total_count"
    case unexplainedTransactionCount = "unexplained_transaction_count"
    case manuallyAddedTransactionCount = "manually_added_transaction_count"
    case accountNumber = "account_number"
    case sortCode = "sort_code"
    case bankCode = "bank_code"
    case latestActivityDate = "latest_activity_date"
    case updatedAt = "updated_at"
    case createdAt = "created_at"
    case email
  }
}

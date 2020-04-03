//
//  FreeAgentModel.swift
//  BeanCounty
//
//  Created by Max Desiatov on 01/04/2020.
//  Copyright © 2020 Digital Signal Limited. All rights reserved.
//

import Foundation

struct FABankAccounts: Codable {
  let bankAccounts: [FABankAccount]

  enum CodingKeys: String, CodingKey {
    case bankAccounts = "bank_accounts"
  }
}

struct FABankAccount: Codable {
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

struct FATransactions: Codable {
  let bankTransactions: [FATransaction]

  enum CodingKeys: String, CodingKey {
    case bankTransactions = "bank_transactions"
  }
}

struct FATransaction: Codable {
  let url: URL
  let amount: FAAmount
  let bankAccount: URL
  let datedOn: Date
  let description, fullDescription: String
  let uploadedAt: Date
  let unexplainedAmount: FAAmount
  let isManual: Bool
  let createdAt, updatedAt: Date
  let matchingTransactionsCount: Int
  let bankTransactionExplanations: [FAExplanation]

  enum CodingKeys: String, CodingKey {
    case url, amount
    case bankAccount = "bank_account"
    case datedOn = "dated_on"
    case description
    case fullDescription = "full_description"
    case uploadedAt = "uploaded_at"
    case unexplainedAmount = "unexplained_amount"
    case isManual = "is_manual"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case matchingTransactionsCount = "matching_transactions_count"
    case bankTransactionExplanations = "bank_transaction_explanations"
  }
}

extension FATransaction: Identifiable {
  var id: URL { url }
}

struct FAExplanation: Codable {
  let bankAccount: URL
  let category: URL
  let datedOn: Date
  let description: String
  let transactionDescription, grossValue: String
  let foreignCurrencyValue: FAAmount
  let transferValue: String
  let type: FATransactionType
  let isMoneyIn, isMoneyOut, isMoneyPaidToUser: Bool
  let linkedTransferExplanation: String?
  let linkedTransferAccount: String?
  let url, bankTransaction, updatedAt, detail: String
  let isLocked: Bool
  let lockedAttributes: [LockedAttribute]?
  let markedForReview, hasPendingOperation: Bool
  let salesTaxStatus, salesTaxRate, salesTaxValue: String?
  let attachment: Attachment?

  enum CodingKeys: String, CodingKey {
    case bankAccount = "bank_account"
    case category
    case datedOn = "dated_on"
    case description
    case transactionDescription = "transaction_description"
    case grossValue = "gross_value"
    case foreignCurrencyValue = "foreign_currency_value"
    case transferValue = "transfer_value"
    case type
    case isMoneyIn = "is_money_in"
    case isMoneyOut = "is_money_out"
    case isMoneyPaidToUser = "is_money_paid_to_user"
    case linkedTransferExplanation = "linked_transfer_explanation"
    case linkedTransferAccount = "linked_transfer_account"
    case url
    case bankTransaction = "bank_transaction"
    case updatedAt = "updated_at"
    case detail
    case isLocked = "is_locked"
    case lockedAttributes = "locked_attributes"
    case markedForReview = "marked_for_review"
    case hasPendingOperation = "has_pending_operation"
    case salesTaxStatus = "sales_tax_status"
    case salesTaxRate = "sales_tax_rate"
    case salesTaxValue = "sales_tax_value"
    case attachment
  }
}

struct Attachment: Codable {
  let url, contentSrc, contentSrcMedium, contentSrcSmall: URL
  let expiresAt: String
  let contentType: String
  let fileName: String
  let fileSize: Int

  enum CodingKeys: String, CodingKey {
    case url
    case contentSrc = "content_src"
    case contentSrcMedium = "content_src_medium"
    case contentSrcSmall = "content_src_small"
    case expiresAt = "expires_at"
    case contentType = "content_type"
    case fileName = "file_name"
    case fileSize = "file_size"
  }
}

enum LockedAttribute: String, Codable {
  case linkedTransferAccount = "linked_transfer_account"
  case transferValue = "transfer_value"
  case type
}

enum FATransactionType: String, Codable {
  case payment = "Payment"
  case transferFromAnotherAccount = "Transfer from Another Account"
  case transferToAnotherAccount = "Transfer to Another Account"
  case invoiceReceipt = "Invoice Receipt"
}

struct FAAmount: Codable {
  let value: Decimal

  init(value: Decimal) {
    self.value = value
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    guard let value = Decimal(string: string) else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "can't decode decimal value"
      )
    }

    self.value = value
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    let string = NumberFormatter().string(from: value as NSNumber)
    try container.encode(string)
  }
}

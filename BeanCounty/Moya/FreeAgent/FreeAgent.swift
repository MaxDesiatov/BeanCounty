//
//  FreeAgent.swift
//  BeanCounty
//
//  Created by Max Desiatov on 31/03/2020.
//  Copyright © 2020 Digital Signal Limited. All rights reserved.
//

import Alamofire
import Foundation
import Moya

struct FAStatement: Codable {
  struct Item: Codable {
    let datedOn: Date
    let amount: Decimal
    let description: String

    enum CodingKeys: String, CodingKey {
      case datedOn = "dated_on"
      case amount
      case description
    }
  }

  let statement: [Item]
}

struct FreeAgent: TargetType {
  let baseURL: URL = URL(string: "https://api.freeagent.com/v2/")!
  let path: String
  let method: HTTPMethod

  let sampleData = Data()

  let task: Task

  let headers: [String: String]?

  let validationType = ValidationType.successCodes
}

extension FreeAgent {
  static let bankAccounts = FreeAgent(
    path: "bank_accounts",
    method: .get,
    task: .requestPlain,
    headers: nil
  )

  static func transactions(_ bankAccount: FABankAccount) -> FreeAgent {
    FreeAgent(
      path: "bank_transactions",
      method: .get,
      task: .requestParameters(
        parameters: ["bank_account": bankAccount.url],
        encoding: URLEncoding()
      ),
      headers: nil
    )
  }

  static func upload(_ bankAccount: FABankAccount, _ statement: FAStatement) throws -> FreeAgent {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .faDate
    let data = try encoder.encode(statement)
    return FreeAgent(
      path: "bank_transactions/statement",
      method: .post,
      task: .requestCompositeData(bodyData: data, urlParameters: ["bank_account": bankAccount.url]),
      headers: ["Content-Type": "application/json"]
    )
  }
}

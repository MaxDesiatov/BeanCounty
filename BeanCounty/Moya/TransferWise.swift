//
//  TransferWise.swift
//  BeanCounty
//
//  Created by Max Desiatov on 26/12/2019.
//  Copyright © 2019 Digital Signal Limited. All rights reserved.
//

import Foundation
import Moya

struct TransferWise: TargetType, AccessTokenAuthorizable {
  let baseURL: URL = URL(string: "https://api.sandbox.transferwise.tech/")!
  let path: String
  let method = Method.get

  let sampleData = Data()

  let task: Task

  let headers: [String: String]? = nil

  let authorizationType: AuthorizationType? = .bearer
}

private let isoFormatter = ISO8601DateFormatter()

private extension Date {
  var isoFormat: String {
    isoFormatter.string(from: self)
  }
}

extension TransferWise {
  static let profiles = TransferWise(path: "v1/profiles", task: .requestPlain)

  static func accounts(profileID: Int) -> TransferWise {
    TransferWise(
      path: "v1/borderless-accounts",
      task: .requestParameters(parameters: ["profileId": profileID], encoding: URLEncoding())
    )
  }

  static func statement(
    profileID: Int,
    accountID: Int,
    currency: String,
    start: Date,
    end: Date
  ) -> TransferWise {
    TransferWise(
      path: "v3/profiles/\(profileID)/borderless-accounts/\(accountID)/statement.json",
      task: .requestParameters(
        parameters: [
          "currency": currency,
          "intervalStart": start.isoFormat,
          "intervalEnd": end.isoFormat,
        ],
        encoding: URLEncoding()
      )
    )
  }
}

//
//  FreeAgent.swift
//  BeanCounty
//
//  Created by Max Desiatov on 31/03/2020.
//  Copyright © 2020 Digital Signal Limited. All rights reserved.
//

import Foundation
import Moya

struct FreeAgent: TargetType {
  let baseURL: URL = URL(string: "https://api.freeagent.com/v2/")!
  let path: String
  let method = Method.get

  let sampleData = Data()

  let task: Task

  let headers: [String: String]? = nil
}

extension FreeAgent {
  static let bankAccounts = FreeAgent(path: "bank_accounts", task: .requestPlain)
}

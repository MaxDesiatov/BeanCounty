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
  let baseURL: URL = URL(string: "https://api.sandbox.transferwise.tech/v1/")!
  let path: String
  let method = Method.get

  let sampleData = Data()

  let task = Task.requestPlain

  let headers: [String: String]? = nil

  let authorizationType: AuthorizationType? = .bearer
}

extension TransferWise {
  static let profiles = TransferWise(path: "profiles")
}

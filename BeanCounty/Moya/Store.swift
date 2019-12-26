//
//  Store.swift
//  BeanCounty
//
//  Created by Max Desiatov on 26/12/2019.
//  Copyright © 2019 Digital Signal Limited. All rights reserved.
//

import Combine
import Moya

struct Profile: Codable {
  let id: Int
  let type: String
  let details: Details
}

// MARK: - Details

struct Details: Codable {
  let firstName, lastName, dateOfBirth, phoneNumber: String?
  let primaryAddress: Int
  let name, registrationNumber: String?
  let companyType, companyRole, descriptionOfBusiness: String?
  let webpage: String?
  let businessCategory, businessSubCategory: String?
}

final class Store: ObservableObject {
  private lazy var provider = MoyaProvider<TransferWise>(plugins: [
    AccessTokenPlugin { [weak self] _ in self?.authToken ?? "" },
  ])

  @Published var authToken = ""

  lazy var profileType = $authToken.flatMap { _ in
    self.provider.requestPublisher(
      .profiles
    )
    .map([Profile].self)
    .map(\.[0].type)
    .catch { _ in
      Just("request failed")
    }
  }
}

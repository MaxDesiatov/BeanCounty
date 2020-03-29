//
//  FreeAgentStore.swift
//  BeanCounty
//
//  Created by Max Desiatov on 29/03/2020.
//  Copyright © 2020 Digital Signal Limited. All rights reserved.
//

import Combine
import KeychainAccess
import OAuthSwift

private let consumerKeyKey = "freeAgentConsumerKey"
private let consumerSecretKey = "freeAgentConsumerSecret"

final class FreeAgentStore: ObservableObject {
  private let oauth = OAuth2Swift(
    consumerKey: "********",
    consumerSecret: "********",
    authorizeUrl: "https://api.freeagent.com/v2/approve_app",
    responseType: "token"
  )

  @Published var consumerKey: String
  @Published var consumerSecret: String

  private let keychain: Keychain
  private var subscriptions = Set<AnyCancellable>()

  init() {
    keychain = Keychain(service: keychainService)
    consumerKey = keychain[consumerKeyKey] ?? ""
    consumerSecret = keychain[consumerSecretKey] ?? ""

    $consumerKey
      // stop rewriting the key just after it's loaded here with `dropFirst`
      .dropFirst()
      // convert from non-optional to optional
      .map { $0 }
      // store updated token in the keychain
      .assign(to: \.[consumerKeyKey], on: keychain)
      .store(in: &subscriptions)

    $consumerSecret
      // stop rewriting the key just after it's loaded here with `dropFirst`
      .dropFirst()
      // convert from non-optional to optional
      .map { $0 }
      // store updated token in the keychain
      .assign(to: \.[consumerSecretKey], on: keychain)
      .store(in: &subscriptions)
  }
}

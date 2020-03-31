//
//  FreeAgentStore.swift
//  BeanCounty
//
//  Created by Max Desiatov on 29/03/2020.
//  Copyright © 2020 Digital Signal Limited. All rights reserved.
//

import Alamofire
import Combine
import Foundation
import KeychainAccess
import Moya
import OAuthSwift
import OAuthSwiftAlamofire

private let consumerKeyKey = "freeAgentConsumerKey"
private let consumerSecretKey = "freeAgentConsumerSecret"
private let credentialKey = "freeAgentCredential"

final class FreeAgentStore: ObservableObject {
  @Published var consumerKey: String
  @Published var consumerSecret: String

  private let keychain: Keychain
  private var subscriptions = Set<AnyCancellable>()

  private var oauth: OAuth2Swift?

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

    let decoder = JSONDecoder()

    guard
      let encodedCredential = keychain[credentialKey],
      let data = encodedCredential.data(using: .utf8),
      let credential = try? decoder.decode(OAuthSwiftCredential.self, from: data)
    else { return }

    setupOAuth()
    oauth?.client = OAuthSwiftClient(credential: credential)
  }

  private func setupOAuth() {
    oauth = OAuth2Swift(
      consumerKey: consumerKey,
      consumerSecret: consumerSecret,
      authorizeUrl: "https://api.freeagent.com/v2/approve_app",
      accessTokenUrl: "https://api.freeagent.com/v2/token_endpoint",
      responseType: "code"
    )
  }

  func authenticate() {
    precondition(!consumerKey.isEmpty)
    precondition(!consumerSecret.isEmpty)

    setupOAuth()

    _ = oauth?.authorize(
      withCallbackURL: "bean-county://oauth-callback/freeagent",
      scope: "",
      state: "FreeAgent"
    ) { result in
      switch result {
      case let .success((credential, _, _)):
        let encoder = JSONEncoder()

        guard
          let data = try? encoder.encode(credential),
          let string = String(data: data, encoding: .utf8)
        else { return }

        self.keychain[credentialKey] = string

        guard let interceptor = self.oauth?.requestInterceptor else { return }

        let session = Session(interceptor: interceptor)

        let provider = MoyaProvider<FreeAgent>(session: session)

        provider.requestPublisher(.bankAccounts)
          .mapString()
          .catch { Just($0.localizedDescription) }
          .sink { print($0) }
          .store(in: &self.subscriptions)
      case let .failure(error):
        print(error.localizedDescription)
      }
    }
  }
}

//
//  CombineHelpers.swift
//  BeanCounty
//
//  Created by Max Desiatov on 02/04/2020.
//  Copyright © 2020 Digital Signal Limited. All rights reserved.
//

import Combine
import KeychainAccess

extension Published.Publisher where Output == String {
  func write(as key: String, to keychain: Keychain) -> AnyCancellable {
    self
      // stop rewriting the key just after it's loaded here with `dropFirst`
      .dropFirst()
      // convert from non-optional to optional
      .map { $0 }
      // store updated token in the keychain
      .assign(to: \.[key], on: keychain)
  }
}

//
//  SettingsView.swift
//  BeanCounty
//
//  Created by Max Desiatov on 26/12/2019.
//  Copyright © 2019 Digital Signal Limited. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
  @State private var token = ""

  @ObservedObject private(set) var store: Store

  var body: some View {
    Form {
      Section(header: Text("Authentication")) {
        SecureField("Token", text: $token)
        Text("Current token is \(token.isEmpty ? "in" : "")valid")
      }
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView(store: Store())
  }
}

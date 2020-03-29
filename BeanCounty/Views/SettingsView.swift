//
//  SettingsView.swift
//  BeanCounty
//
//  Created by Max Desiatov on 26/12/2019.
//  Copyright © 2019 Digital Signal Limited. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
  @ObservedObject private(set) var transferWise: TransferWiseStore
  @ObservedObject private(set) var freeAgent: FreeAgentStore

  var body: some View {
    Form {
      Section(header: Text("TransferWise Authentication")) {
        SecureField(
          "Token",
          text: $transferWise.token
        )
        Text("Current token is \(transferWise.token.isEmpty ? "in" : "")valid")
      }
      Section(header: Text("FreeAgent Authentication")) {
        SecureField(
          "Consumer Key",
          text: $freeAgent.consumerKey
        )
        SecureField(
          "Consumer Secret",
          text: $freeAgent.consumerSecret
        )
      }
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView(
      transferWise: TransferWiseStore(), freeAgent: FreeAgentStore()
    )
  }
}

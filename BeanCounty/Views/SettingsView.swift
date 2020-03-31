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

  var profiles: [Profile]? {
    try? transferWise.availableProfiles?.get()
  }

  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("TransferWise Authentication")) {
          SecureField(
            "Token",
            text: $transferWise.token
          )
          Text("Current token is \(transferWise.token.isEmpty ? "in" : "")valid")
          if profiles != nil {
            Picker("Profile", selection: $transferWise.selectedProfileIndex) {
              ForEach(0..<profiles!.count) {
                Text(self.profiles![$0].type)
              }
            }
          }
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
          Button(action: { self.freeAgent.authenticate() }) {
            Text("Authenticate")
          }.disabled(freeAgent.consumerKey.isEmpty || freeAgent.consumerSecret.isEmpty)
        }
      }
      .navigationBarTitle("Settings")
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView(
      transferWise: TransferWiseStore(), freeAgent: FreeAgentStore()
    )
  }
}

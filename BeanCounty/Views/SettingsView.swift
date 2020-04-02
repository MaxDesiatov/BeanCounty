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

  var bankAccounts: [FABankAccount]? {
    try? freeAgent.bankAccounts?.get()
  }

  var transactions: [FATransaction]? {
    try? freeAgent.transactions?.get()
  }

  var body: some View {
    return NavigationView {
      Form {
        Section(header: Text("TransferWise Authentication")) {
          SecureField(
            "Token",
            text: $transferWise.token
          )

          Text("Current token is \(transferWise.token.isEmpty ? "in" : "")valid")

          ResultItemSelector(
            result: transferWise.availableProfiles,
            title: "Profile",
            selection: $transferWise.selectedProfileIndex,
            itemText: \.type
          )
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

          ResultItemSelector(
            result: freeAgent.bankAccounts,
            title: "Bank Account",
            selection: $freeAgent.selectedBankAccountIndex,
            itemText: \.name
          )

          if transactions != nil {
            NavigationLink(
              destination: FATransactionsList(transactions: transactions!)
            ) {
              Text("Transactions List")
            }
          }

          Button(action: { self.freeAgent.isAuthenticated ?
              self.freeAgent.signOut() : self.freeAgent.authenticate()
          }) {
            Text(freeAgent.isAuthenticated ? "Sign Out" : "Authenticate")
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

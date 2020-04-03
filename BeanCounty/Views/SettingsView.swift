//
//  SettingsView.swift
//  BeanCounty
//
//  Created by Max Desiatov on 26/12/2019.
//  Copyright © 2019 Digital Signal Limited. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
  @ObservedObject private(set) var twStore: TransferWiseStore
  @ObservedObject private(set) var faStore: FreeAgentStore

  var bankAccounts: [FABankAccount]? {
    try? faStore.bankAccounts?.get()
  }

  var transactions: [FATransaction]? {
    try? faStore.transactions?.get()
  }

  var body: some View {
    return NavigationView {
      Form {
        Section(header: Text("TransferWise Authentication")) {
          SecureField(
            "Token",
            text: $twStore.token
          )

          Text("Current token is \(twStore.token.isEmpty ? "in" : "")valid")

          ResultItemSelector(
            result: twStore.availableProfiles,
            title: "Profile",
            selection: $twStore.selectedProfileIndex,
            itemText: \.type
          )
        }

        Section(header: Text("FreeAgent Authentication")) {
          SecureField(
            "Consumer Key",
            text: $faStore.consumerKey
          )

          SecureField(
            "Consumer Secret",
            text: $faStore.consumerSecret
          )

          ResultItemSelector(
            result: faStore.bankAccounts,
            title: "Bank Account",
            selection: $faStore.selectedBankAccountIndex,
            itemText: \.name
          )

          if transactions != nil {
            Group {
              NavigationLink(
                destination: FATransactionsList(transactions: transactions!)
              ) {
                Text("Transactions List")
              }
              XLSXUpload(runner: Runner {
                // swiftlint:disable force_try
                try! self.faStore.uploadXLSX()
              })
            }
          }

          Button(action: { self.faStore.isAuthenticated ?
              self.faStore.signOut() : self.faStore.authenticate()
          }) {
            Text(faStore.isAuthenticated ? "Sign Out" : "Authenticate")
          }.disabled(faStore.consumerKey.isEmpty || faStore.consumerSecret.isEmpty)
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
      twStore: TransferWiseStore(), faStore: FreeAgentStore()
    )
  }
}

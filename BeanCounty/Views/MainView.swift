//
//  MainView.swift
//  BeanCounty
//
//  Created by Max Desiatov on 11/12/2019.
//  Copyright © 2019 Digital Signal Limited. All rights reserved.
//

import SwiftUI

private let dateFormatter: DateFormatter = {
  let dateFormatter = DateFormatter()
  dateFormatter.dateStyle = .medium
  dateFormatter.timeStyle = .medium
  return dateFormatter
}()

struct MainView<Style: NavigationViewStyle>: View {
  @State private var balances = [(accountID: Int, balance: Balance)]()

  @ObservedObject var store: Store

  @State var profileType: String = "loading..."

  let style: Style

  var body: some View {
    NavigationView {
      AccountsList(balances: balances) { self.store.statement(accountID: $0, currency: $1) }
        .navigationBarTitle(Text(profileType))
        .navigationBarItems(
          leading: EditButton(),
          trailing: Button(
            action: {
              UIApplication
                .shared
                .requestSceneSessionActivation(
                  nil,
                  userActivity: Activity.settings.userActivity,
                  options: nil,
                  errorHandler: nil
                )
            }
          ) {
            Image(systemName: "gear")
          }
        )
      Text("Select an account on the left side to view its statement")
    }
    .navigationViewStyle(style)
    .onReceive(store.selectedProfile) {
      switch $0 {
      case let .success(profile):
        self.profileType = profile.type
      case let .failure(error):
        self.profileType = error.localizedDescription
      }
    }
    .onReceive(store.accounts) {
      switch $0 {
      case let .success(accounts):
        self.balances = accounts
          .flatMap { account in account.balances.map { (accountID: account.id, balance: $0) } }
      case let .failure(error):
        self.profileType = error.localizedDescription
      }
    }
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView(
      store: Store(availableProfiles: .success([Profile(
        id: 42,
        type: "personal",
        details: Details(
          firstName: "Test",
          lastName: "User",
          dateOfBirth: nil,
          phoneNumber: nil,
          primaryAddress: 42,
          name: "Name",
          registrationNumber: nil,
          companyType: nil,
          companyRole: nil,
          descriptionOfBusiness: nil,
          webpage: nil,
          businessCategory: nil,
          businessSubCategory: nil
        )
      )])),
      style: StackNavigationViewStyle()
    )
  }
}

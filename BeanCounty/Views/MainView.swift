//
//  MainView.swift
//  BeanCounty
//
//  Created by Max Desiatov on 11/12/2019.
//  Copyright © 2019 Digital Signal Limited. All rights reserved.
//

import Combine
import SwiftUI

private let dateFormatter: DateFormatter = {
  let dateFormatter = DateFormatter()
  dateFormatter.dateStyle = .medium
  dateFormatter.timeStyle = .medium
  return dateFormatter
}()

struct MainView<Style: NavigationViewStyle>: View {
  @State private var balances = [(accountID: Int, balance: Balance)]()

  @ObservedObject var twStore: TransferWiseStore
  let faStore: FreeAgentStore

  @State var profileType: String = "loading..."

  let style: Style

  var body: some View {
    NavigationView {
      AccountList(
        balances: balances,
        onSelect: { self.twStore.statement(accountID: $0, currency: $1) },
        onUpload: { _ in Just(.success(())).eraseToAnyPublisher() }
      )
      .navigationBarTitle(Text(profileType), displayMode: .inline)
      .navigationBarItems(
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
    .onReceive(twStore.selectedProfile) {
      switch $0 {
      case let .success(profile):
        self.profileType = profile.type
      case let .failure(error):
        self.profileType = error.localizedDescription
      }
    }
    .onReceive(twStore.accounts) {
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
      twStore: TransferWiseStore(availableProfiles: .success([Profile(
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
      faStore: FreeAgentStore(),
      style: StackNavigationViewStyle()
    )
  }
}

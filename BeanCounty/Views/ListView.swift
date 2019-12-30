//
//  ListView.swift
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

struct ListView: View {
  @State private var balances = [Balance]()

  @ObservedObject var store: Store

  @State var profileType: String = "loading..."

  var body: some View {
    NavigationView {
      MasterView(balances: $balances)
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
      DetailView()
    }
    .navigationViewStyle(DoubleColumnNavigationViewStyle())
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
        self.balances = accounts.flatMap { $0.balances }
      case let .failure(error):
        self.profileType = error.localizedDescription
      }
    }
  }
}

struct MasterView: View {
  @Binding var balances: [Balance]

  var body: some View {
    List {
      ForEach(balances, id: \.self) { balance in
        NavigationLink(
          destination: DetailView(text: "blah")
        ) {
          Text("\(balance.amount.value as NSNumber) \(balance.currency)")
        }
      }
    }
  }
}

struct DetailView: View {
  var text: String?

  var body: some View {
    Group {
      if text != nil {
        Text(text!)
      } else {
        Text("Detail view content goes here")
      }
    }.navigationBarTitle(Text("Detail"))
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ListView(store: Store())
  }
}

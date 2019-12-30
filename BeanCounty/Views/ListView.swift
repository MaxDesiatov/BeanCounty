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
  @State private var accounts = [Account]()

  @ObservedObject var store: Store

  @State var profileType: String = "loading..."

  var body: some View {
    NavigationView {
      MasterView(accounts: $accounts)
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
        self.accounts = accounts
      case let .failure(error):
        self.profileType = error.localizedDescription
      }
    }
  }
}

struct MasterView: View {
  @Binding var accounts: [Account]

  var body: some View {
    List {
      ForEach(accounts, id: \.self) { account in
        NavigationLink(
          destination: DetailView(selectedDate: account.creationTime)
        ) {
          Text(account.creationTime)
        }
      }.onDelete { indices in
        indices.forEach { self.accounts.remove(at: $0) }
      }
    }
  }
}

struct DetailView: View {
  var selectedDate: String?

  var body: some View {
    Group {
      if selectedDate != nil {
        Text(selectedDate!)
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

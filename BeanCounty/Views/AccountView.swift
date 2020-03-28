//
//  AccountView.swift
//  BeanCounty
//
//  Created by Max Desiatov on 28/03/2020.
//  Copyright © 2020 Digital Signal Limited. All rights reserved.
//

import Combine
import SwiftUI

struct AccountView: View {
  let accountID: Int
  let balance: Balance

  let onLoad: (_ accountID: Int, _ currency: String) -> ResultPublisher<[Transaction]>

  @State private var transactions: [Transaction]?

  @State private var text: String = "loading..."

  var body: some View {
    Group {
      if self.transactions != nil {
        List {
          ForEach(transactions!) { item in
            Text("\(item.amount.value as NSNumber)")
          }
        }
      } else {
        Text("loading...")
      }
    }
    .navigationBarTitle(Text("\(balance.amount.value as NSNumber) \(balance.currency)"))
    .onReceive(onLoad(accountID, balance.currency)) {
      switch $0 {
      case let .success(transactions):
        self.transactions = transactions
      case let .failure(error):
        self.text = error.localizedDescription
      }
    }
  }
}

struct AccountView_Previews: PreviewProvider {
  static var previews: some View {
    AccountView(
      accountID: 0,
      balance: Balance(
        balanceType: "",
        currency: "EUR",
        amount: Amount(value: 0, currency: "EUR")
      )
    ) { _, _ in Just(.success([])).eraseToAnyPublisher() }
  }
}

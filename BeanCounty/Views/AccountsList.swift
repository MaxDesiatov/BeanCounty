//
//  AccountsList.swift
//  BeanCounty
//
//  Created by Max Desiatov on 29/02/2020.
//  Copyright © 2020 Digital Signal Limited. All rights reserved.
//

import Combine
import SwiftUI

struct AccountsList: View {
  let balances: [(accountID: Int, balance: Balance)]

  let onSelect: (_ accountID: Int, _ currency: String) -> ResultPublisher<[Transaction]>

  var body: some View {
    List {
      ForEach(balances, id: \.balance.id) { item in
        NavigationLink(
          destination: AccountView(
            accountID: item.accountID,
            balance: item.balance,
            onLoad: self.onSelect
          )
        ) {
          Text("\(item.balance.amount.value as NSNumber) \(item.balance.currency)")
        }
      }
    }
  }
}

struct AccountsList_Previews: PreviewProvider {
  static var previews: some View {
    AccountsList(balances: [
      (0, Balance(
        balanceType: "",
        currency: "EUR",
        amount: Amount(value: 10, currency: "EUR")
      )),
      (0, Balance(
        balanceType: "",
        currency: "USD",
        amount: Amount(value: 10, currency: "EUR")
      )),
    ]) { _, _ in Just(.success([])).eraseToAnyPublisher() }
  }
}

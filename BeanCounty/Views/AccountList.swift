//
//  AccountList.swift
//  BeanCounty
//
//  Created by Max Desiatov on 29/02/2020.
//  Copyright © 2020 Digital Signal Limited. All rights reserved.
//

import Combine
import SwiftUI

struct AccountList: View {
  let balances: [(accountID: Int, balance: Balance)]
  let faStore: FreeAgentStore

  let onSelect: (_ accountID: Int, _ currency: String) -> ResultPublisher<[TWTransaction]>

  var body: some View {
    List {
      ForEach(balances, id: \.balance.id) { item in
        NavigationLink(
          destination: AccountView(
            accountID: item.accountID,
            balance: item.balance,
            faStore: self.faStore,
            runner: Runner(self.onSelect(item.accountID, item.balance.currency))
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
    AccountList(
      balances: [
        (0, Balance(
          balanceType: "",
          currency: "EUR",
          amount: TWAmount(value: 10, currency: "EUR")
        )),
        (0, Balance(
          balanceType: "",
          currency: "USD",
          amount: TWAmount(value: 10, currency: "EUR")
        )),
      ],
      faStore: FreeAgentStore(),
      onSelect: { _, _ in Just(.success([])).eraseToAnyPublisher() }
    )
  }
}

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

  let onSelect: (_ accountID: Int, _ currency: String) -> ResultPublisher<[TWTransaction]>
  let onUpload: (_ transactions: [TWTransaction]) -> ResultPublisher<()>

  var body: some View {
    List {
      ForEach(balances, id: \.balance.id) { item in
        NavigationLink(
          destination: AccountView(
            accountID: item.accountID,
            balance: item.balance,
            onLoad: self.onSelect,
            onUpload: self.onUpload
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
      onSelect: { _, _ in Just(.success([])).eraseToAnyPublisher() },
      onUpload: { _ in Just(.success(())).eraseToAnyPublisher() }
    )
  }
}

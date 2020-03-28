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

  @State var transactions: [Transaction]?

  @State private var text: String = "loading..."

  var body: some View {
    Group {
      if self.transactions != nil {
        List {
          ForEach(transactions!) {
            Text("""
            \($0.amount.description) \($0.date), \
            fee \($0.totalFees.description), balance \($0.runningBalance.description)
            """)
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
      ),
      onLoad: { _, _ in Just(.success([])).eraseToAnyPublisher() },
      transactions: [
        Transaction(
          type: "blah",
          date: "date",
          amount: Amount(value: 10, currency: "EUR"),
          totalFees: Amount(value: 2, currency: "EUR"),
          details: TransactionDetails(
            type: "type",
            detailsDescription: "detailsDescription",
            amount: nil,
            category: nil,
            merchant: nil,
            senderName: nil,
            senderAccount: nil,
            paymentReference: nil,
            sourceAmount: nil,
            targetAmount: nil,
            fee: nil,
            rate: 4.25
          ),
          exchangeDetails: nil,
          runningBalance: Amount(value: 345, currency: "EUR"),
          referenceNumber: "referenceNumber"
        ),
      ]
    )
  }
}

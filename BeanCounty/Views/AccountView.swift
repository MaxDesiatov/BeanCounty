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
          ForEach(transactions!) { item in
            HStack {
              VStack(alignment: .leading, spacing: 10) {
                Text("\(item.date.value, formatter: Self.dateFormater)").foregroundColor(.secondary)
                Text(item.amount.description)
                Text("fee \(item.totalFees.description)").foregroundColor(.red)
              }
              Spacer()
              VStack(alignment: .trailing, spacing: 10) {
                Text("balance")
                Text("\(item.runningBalance.description)").foregroundColor(.green)
              }
            }
          }
        }
      } else {
        Text(text)
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

  private static let dateFormater: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter
  }()
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
          date: ISODate(value: Date()),
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

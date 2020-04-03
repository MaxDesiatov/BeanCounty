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
  let faStore: FreeAgentStore

  @State var transactions: [TWTransaction]?

  @ObservedObject var runner: Runner<[TWTransaction]>

  var body: some View {
    Group { () -> AnyView in
      switch runner.state {
      case let .failure(error):
        return AnyView(Text(error.localizedDescription))
      case let .success(transactions):
        return AnyView(List {
          UploadButton(transactions: transactions, runner: Runner(faStore.upload(transactions)))
          ForEach(transactions) { item in
            HStack {
              VStack(alignment: .leading, spacing: 10) {
                Text("\(item.date, formatter: Self.dateFormater)").foregroundColor(.secondary)
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
        })
      default:
        return AnyView(Text("loading..."))
      }
    }
    .navigationBarTitle(Text("\(balance.amount.value as NSNumber) \(balance.currency)"))
    .onAppear {
      self.runner.run()
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
        amount: TWAmount(value: 0, currency: "EUR")
      ),
      faStore: FreeAgentStore(),
      transactions: [
        TWTransaction(
          type: "blah",
          date: Date(),
          amount: TWAmount(value: 10, currency: "EUR"),
          totalFees: TWAmount(value: 2, currency: "EUR"),
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
          runningBalance: TWAmount(value: 345, currency: "EUR"),
          referenceNumber: "referenceNumber"
        ),
      ],
      runner: Runner(Just(.success([])).eraseToAnyPublisher())
    )
  }
}

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

  let onLoad: (_ accountID: Int, _ currency: String) -> ResultPublisher<[TWTransaction]>
  let onUpload: (_ transactions: [TWTransaction]) -> ResultPublisher<()>

  @State var transactions: [TWTransaction]?

  @State private var text: String = "loading..."

  @State var isUploading = false

  var body: some View {
    Group {
      if self.transactions != nil {
        List {
          if isUploading {
            Text("Uploading to FreeAgent...").onReceive(onUpload(transactions!)) {
              print("uploaded with result \($0)")
            }
          } else {
            Button(action: { print("blah") }) {
              Text("Upload to FreeAgent")
            }
          }
          ForEach(transactions!) { item in
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
        amount: TWAmount(value: 0, currency: "EUR")
      ),
      onLoad: { _, _ in Just(.success([])).eraseToAnyPublisher() },
      onUpload: { _ in Just(.success(())).eraseToAnyPublisher() },
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
      ]
    )
  }
}

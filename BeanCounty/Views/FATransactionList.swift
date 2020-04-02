//
//  FATransactionList.swift
//  BeanCounty
//
//  Created by Max Desiatov on 02/04/2020.
//  Copyright © 2020 Digital Signal Limited. All rights reserved.
//

import SwiftUI

struct FATransactionsList: View {
  let transactions: [FATransaction]

  var body: some View {
    List {
      ForEach(transactions) { item in
        VStack(alignment: .leading, spacing: 10) {
          Text("\(item.datedOn, formatter: Self.dateFormater)").foregroundColor(.secondary)
          Text(item.description)
          Text("amount $\(item.amount.value.description)").foregroundColor(.red)
        }
      }
    }
  }

  private static let dateFormater: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter
  }()
}

struct FATransactionList_Previews: PreviewProvider {
  static var previews: some View {
    FATransactionsList(transactions: [
      FATransaction(
        url: URL(string: "https://freeagent.com")!,
        amount: FAAmount(value: 1.25),
        bankAccount: URL(string: "https://freeagent.com")!,
        datedOn: Date(),
        description: "Blah",
        fullDescription: "Blah FOO bar",
        uploadedAt: Date(),
        unexplainedAmount: FAAmount(value: 0),
        isManual: false,
        createdAt: Date(),
        updatedAt: Date(),
        matchingTransactionsCount: 2,
        bankTransactionExplanations: []
      ),
    ])
  }
}

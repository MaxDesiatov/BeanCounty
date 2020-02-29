//
//  AccountsList.swift
//  BeanCounty
//
//  Created by Max Desiatov on 29/02/2020.
//  Copyright © 2020 Digital Signal Limited. All rights reserved.
//

import SwiftUI

struct AccountsList: View {
  @Binding var balances: [Balance]

  var body: some View {
    List {
      ForEach(balances, id: \.self) { balance in
        NavigationLink(
          destination: DetailView(text: "blah")
        ) {
          Text("\(balance.amount.value as NSNumber) \(balance.currency)")
        }
      }
    }
  }
}

//
//  ResultItemSelector.swift
//  BeanCounty
//
//  Created by Max Desiatov on 02/04/2020.
//  Copyright © 2020 Digital Signal Limited. All rights reserved.
//

import SwiftUI

struct ResultItemSelector<Item>: View {
  let result: MoyaResult<[Item]>?
  let title: String
  let selection: Binding<Int>
  let itemText: KeyPath<Item, String>

  var items: [Item]? { try? result?.get() }

  var body: some View {
    guard let items = items else { return AnyView(EmptyView()) }

    return AnyView(Picker(title, selection: selection) {
      ForEach(0..<items.count) {
        Text(items[$0][keyPath: self.itemText])
      }
    })
  }
}

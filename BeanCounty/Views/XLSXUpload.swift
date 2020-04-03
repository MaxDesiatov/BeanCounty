//
//  XLSXUpload.swift
//  BeanCounty
//
//  Created by Max Desiatov on 03/04/2020.
//  Copyright © 2020 Digital Signal Limited. All rights reserved.
//

import SwiftUI

struct XLSXUpload: View {
  @ObservedObject var runner: Runner<()>

  var body: some View {
    switch runner.state {
    case let .failure(error):
      return AnyView(Text(error.localizedDescription))
    case .running:
      return AnyView(Text("running..."))
    default:
      return AnyView(Button(action: { self.runner.run() }) {
        Text("Upload XLSX to FreeAgent")
      })
    }
  }
}

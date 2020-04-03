//
//  UploadButton.swift
//  BeanCounty
//
//  Created by Max Desiatov on 03/04/2020.
//  Copyright © 2020 Digital Signal Limited. All rights reserved.
//

import SwiftUI

struct UploadButton: View {
  let transactions: [TWTransaction]

  @ObservedObject var runner: Runner<()>

  var body: some View {
    switch self.runner.state {
    case .running:
      return AnyView(Text("Uploading to FreeAgent..."))
    default:
      return AnyView(Button(action: { self.runner.run() }) {
        Text("Upload to FreeAgent")
      })
    }
  }
}

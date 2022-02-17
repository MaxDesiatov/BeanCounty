//
//  main.swift
//  upwork2fa
//
//  Created by Max Desiatov on 16/02/2022.
//  Copyright © 2022 Digital Signal Limited. All rights reserved.
//

import CSV
import Foundation

let inputFormatter: DateFormatter = {
  let result = DateFormatter()
  result.dateStyle = .medium
  result.timeStyle = .none
  result.locale = Locale(identifier: "en_US")
  return result
}()

let outputFormatter: DateFormatter = {
  let result = DateFormatter()
  result.dateFormat = "dd/MM/yyyy"
  return result
}()

let decimalFormatter: NumberFormatter = {
  let result = NumberFormatter()
  result.numberStyle = .currency
  result.currencySymbol = ""
  result.groupingSeparator = ""
  result.currencyGroupingSeparator = ""
  return result
}()

enum TransactionType: String {
  case vat = "VAT"
  case serviceFee = "Service Fee"
  case hourly = "Hourly"
  case withdrawal = "Withdrawal"
}

guard
  let first = CommandLine.arguments.first,
  let last = CommandLine.arguments.last,
  first != last
else {
  fatalError("file argument not passed")
}

let inputStream = InputStream(fileAtPath: last)!
let csv = try! CSVReader(stream: inputStream)

var lastServiceFee: Decimal?
var lastServiceFeeDesc: String?
var results = [(Date, Decimal, String)]()

for row in csv.dropFirst().reversed() {
  let date = inputFormatter.date(from: row[0])!
  let type = TransactionType(rawValue: row[2])!
  var amount = Decimal(string: row[9])!
  let description: String

  switch type {
  case .vat:
    description = lastServiceFeeDesc!
    amount += lastServiceFee!
  case .serviceFee:
    lastServiceFee = amount
    lastServiceFeeDesc = row[3]
    continue
  case .withdrawal:
    description = type.rawValue + " " + row[3]
  case .hourly:
    description = row[3]
    lastServiceFee = nil
    lastServiceFeeDesc = nil
  }

  let result = (date, amount, description)
  results.append(result)
}

let outputStream = OutputStream(toFileAtPath: URL(fileURLWithPath: last).deletingLastPathComponent().appendingPathComponent("freeagent.csv").path, append: false)!
let writer = try CSVWriter(stream: outputStream)

for (date, amount, description) in results {
  try writer.write(row: [outputFormatter.string(from: date), decimalFormatter.string(from: amount as NSNumber)!, description])
}

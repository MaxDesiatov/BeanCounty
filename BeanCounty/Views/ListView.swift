//
//  ListView.swift
//  BeanCounty
//
//  Created by Max Desiatov on 11/12/2019.
//  Copyright © 2019 Digital Signal Limited. All rights reserved.
//

import SwiftUI

private let dateFormatter: DateFormatter = {
  let dateFormatter = DateFormatter()
  dateFormatter.dateStyle = .medium
  dateFormatter.timeStyle = .medium
  return dateFormatter
}()

struct ListView: View {
  @State private var dates = [Date]()

  @ObservedObject var store: Store

  @State var profileType: String = "loading..."

  var body: some View {
    NavigationView {
      MasterView(dates: $dates)
        .navigationBarTitle(Text(profileType))
        .navigationBarItems(
          leading: EditButton(),
          trailing: Button(
            action: {
              UIApplication
                .shared
                .requestSceneSessionActivation(
                  nil,
                  userActivity: Activity.settings.userActivity,
                  options: nil,
                  errorHandler: nil
                )
//              withAnimation { self.dates.insert(Date(), at: 0) }
            }
          ) {
            Image(systemName: "plus")
          }
        )
      DetailView()
    }
    .navigationViewStyle(DoubleColumnNavigationViewStyle())
    .onReceive(store.profileType) { self.profileType = $0 }
  }
}

struct MasterView: View {
  @Binding var dates: [Date]

  var body: some View {
    List {
      ForEach(dates, id: \.self) { date in
        NavigationLink(
          destination: DetailView(selectedDate: date)
        ) {
          Text("\(date, formatter: dateFormatter)")
        }
      }.onDelete { indices in
        indices.forEach { self.dates.remove(at: $0) }
      }
    }
  }
}

struct DetailView: View {
  var selectedDate: Date?

  var body: some View {
    Group {
      if selectedDate != nil {
        Text("\(selectedDate!, formatter: dateFormatter)")
      } else {
        Text("Detail view content goes here")
      }
    }.navigationBarTitle(Text("Detail"))
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ListView(store: Store())
  }
}

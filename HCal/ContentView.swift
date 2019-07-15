//
//  ContentView.swift
//  HCal
//
//  Created by Gerard Iglesias on 08/07/2019.
//

import SwiftUI

struct ContentView : View {
  @State var date: Date {
    didSet {
      print("Hello World\n")
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      Text("Goal Date").bold()
      
      DatePicker($date,
                 minimumDate: Calendar.current.date(byAdding: .year, value: -1, to: Date()),
                 maximumDate: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
                 displayedComponents: .date)

      DayView(date: $date)
  }
  }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
  static var previews: some View {
    ContentView(date: Date())
  }
}
#endif

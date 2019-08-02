//
//  ContentView.swift
//  HCal
//
//  Created by Gerard Iglesias on 08/07/2019.
//

import SwiftUI

struct MainCalendarView : View {
  @EnvironmentObject var hcal: HCal
  @State var date: Date {
    didSet {
      print("Hello World\n")
    }
  }
  
  var body: some View {
    VStack {
      MonthSelector(date: $date)
      MonthGrid(date: $date)
    }
    .touchBar {
      HStack {
        Button(action: {
          
        }){
          Text("Hello World")
        }
      }
    }
  }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
  static var previews: some View {
    MainCalendarView(date: Date())
  }
}
#endif

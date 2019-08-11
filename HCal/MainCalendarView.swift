//
//  ContentView.swift
//  HCal
//
//  Created by Gerard Iglesias on 08/07/2019.
//

import SwiftUI

struct MainCalendarView : View {
  @EnvironmentObject var hcal: HCal
  
  var body: some View {
    VStack {
      MonthSelector()
      MonthGrid()
    }
  }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
  static var previews: some View {
    MainCalendarView().environmentObject(HCal())
      .frame(width: nil, height: 800, alignment: .center)
  }
}
#endif

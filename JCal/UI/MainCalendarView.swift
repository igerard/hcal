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
        
    VStack(alignment: .center) {
      MonthSelector()
      MonthGrid()
    }
    .frame(minWidth: 800, minHeight: 650, alignment: .center)
  }
}


#if DEBUG
struct MainCalendarView_Previews : PreviewProvider {
  static var previews: some View {
    Group {
      MainCalendarView()
        .environmentObject(HCal())
        .frame(width: nil, height: 700, alignment: .center)
    }
  }
}
#endif

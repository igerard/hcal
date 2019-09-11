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
    .touchBar(TouchBar(id: "Grid") {
      Text("Hello World")
    })
    .touchBarItemPrincipal(true)
      .touchBarItemPresence(.required("test"))
    .frame(width: 900,
           height: 800,
           alignment: .center)

  }
}


#if DEBUG
struct MainCalendarView_Previews : PreviewProvider {
  static var previews: some View {
    MainCalendarView().environmentObject(HCal())
      .frame(width: nil, height: 800, alignment: .center)
  }
}
#endif

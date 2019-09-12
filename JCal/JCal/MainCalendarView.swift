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
        
    return VStack {
      MonthSelector()
      MonthGrid()
    }
    .frame(width: 900,
           height: 800,
           alignment: .center)
    .touchBar(TouchBar(id: "com.visual-science.Jcal.Grid") {CalTouchBar()})
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

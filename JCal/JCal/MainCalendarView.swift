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
    .frame(width: 900,
           height: 800,
           alignment: .center)
    .touchBar(TouchBar(id: "com.visual-science.Jcal.Grid") {
      Spacer()
      HStack{
        Button(action: {
          self.hcal.calendarType = (self.hcal.calendarType == .gregorian ? .julian : .gregorian)
        }, label: {
          Text(self.hcal.calendarType == .gregorian ? "Julian" : "Gregorian")
        })
        Button(action: {
          self.hcal.holidayArea = (self.hcal.holidayArea == .diaspora ? .israel : .diaspora)
        }, label: {
          Text(self.hcal.holidayArea == .diaspora ? "Israel" : "Diaspora")
        })
      }
      Spacer()
      HStack{
        Button(action: {
          self.hcal.parchaActive = !self.hcal.parchaActive
        }, label: {
          Text("Parsha")
        }).foregroundColor(self.hcal.parchaActive ? Color.blue : Color.white)
        Button(action: {
          self.hcal.omerActive = !self.hcal.omerActive
        }, label: {
          Text("Omer")
        }).foregroundColor(self.hcal.omerActive ? Color.blue : Color.white)
        Button(action: {
          self.hcal.cholActive = !self.hcal.cholActive
        }, label: {
          Text("Chol")
        }).foregroundColor(self.hcal.cholActive ? Color.blue : Color.white)
      }
      Spacer()
      HStack{
        Button(action: {
          self.hcal.decrementMonth()
        }, label: {
          Text("⇦")
        })
        Button(action: {
          self.hcal.toThisYearAndMonth()
        }, label: {
          Text("♢")
        })
        Button(action: {
          self.hcal.incrementMonth()
        }, label: {
          Text("⇨")
        })
      }
      Spacer()
    })
//    .touchBarItemPrincipal(true)
//      .touchBarItemPresence(.default("main"))
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

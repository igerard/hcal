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
      HStack {
        SegmentedControl(selection: $hcal.holidayArea) {
          ForEach(HolidayArea.allCases, id: \.self) { area in
            Text(area.rawValue).tag(area)
          }
        }
        Spacer()
        SegmentedControl(selection: $hcal.calendarType) {
          ForEach(CalendarType.allCases, id: \.self) { cal in
            Text(cal.rawValue).tag(cal)
          }
        }
        Spacer()
        Toggle(isOn: $hcal.parchaActive, label: {
          Text("Parcha")
        })
        Spacer()
        Toggle(isOn: $hcal.omerActive, label: {
          Text("Omer")
        })
        Spacer()
        Toggle(isOn: $hcal.cholActive, label: {
          Text("Chol")
        })
        Spacer()
      }
      .fixedSize(horizontal: false, vertical: true)
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

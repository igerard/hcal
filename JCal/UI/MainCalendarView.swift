//
//  ContentView.swift
//  HCal
//
//  Created by Gerard Iglesias on 08/07/2019.
//

import SwiftUI

struct MainCalendarView : View {
  @Environment(HebrewCalendar.self) private var hcal

  var body: some View {
    @Bindable var hcal = hcal

    VStack(alignment: .center) {
      MonthSelector()
      MonthGrid()
    }
    .frame(minWidth: 800, minHeight: 650, alignment: .center)
    .toolbar {
      ToolbarItemGroup {
        Picker("Calendar", selection: $hcal.calendarType) {
          Text("Gregorian").tag(CalendarType.gregorian)
          Text("Julian").tag(CalendarType.julian)
        }
        .pickerStyle(.segmented)

        Picker("Area", selection: $hcal.holidayArea) {
          Text("Diaspora").tag(HolidayArea.diaspora)
          Text("Israel").tag(HolidayArea.israel)
        }
        .pickerStyle(.segmented)

        HolidayIconToggle(systemImage: "scroll.fill",
                          activeColor: Theming.holidayCategoryColor(.parsha),
                          help: "Parsha",
                          isOn: $hcal.parchaActive)
        HolidayIconToggle(systemImage: "leaf.fill",
                          activeColor: Theming.holidayCategoryColor(.omer),
                          help: "Omer",
                          isOn: $hcal.omerActive)
        HolidayIconToggle(systemImage: "tent.fill",
                          activeColor: Theming.holidayCategoryColor(.intermediate),
                          help: "Chol Hamoed",
                          isOn: $hcal.cholActive)
      }
    }
  }
}

/// A toolbar toggle that conveys state through the SF Symbol itself: gray when
/// off, in its category color when on — no button background highlight.
struct HolidayIconToggle: View {
  let systemImage: String
  let activeColor: Color
  let help: LocalizedStringKey
  @Binding var isOn: Bool

  var body: some View {
    Button {
      isOn.toggle()
    } label: {
      Image(systemName: systemImage)
        .font(.title3)
        .foregroundStyle(isOn ? activeColor : Color.secondary)
        .opacity(isOn ? 1 : 0.55)
    }
    .buttonStyle(.automatic)
    .help(help)
  }
}


#Preview {
  MainCalendarView()
    .environment(HebrewCalendar())
    .frame(height: 700)
}

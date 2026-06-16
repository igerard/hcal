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

        HolidayIconToggle(emoji: "📖", help: "Parsha", isOn: $hcal.parchaActive)
        HolidayIconToggle(emoji: "🔥", help: "Omer", isOn: $hcal.omerActive)
        HolidayIconToggle(emoji: "⛺️", help: "Chol Hamoed", isOn: $hcal.cholActive)
      }
    }
  }
}

/// A toolbar toggle that keeps its emoji icon but conveys state through the
/// glyph itself: desaturated and dimmed when off, full color when on — no
/// button background highlight.
struct HolidayIconToggle: View {
  let emoji: String
  let help: LocalizedStringKey
  @Binding var isOn: Bool

  var body: some View {
    Button {
      isOn.toggle()
    } label: {
      Text(emoji)
        .font(.title3)
        .grayscale(isOn ? 0 : 1)
        .opacity(isOn ? 1 : 0.4)
    }
    .buttonStyle(.plain)
    .help(help)
  }
}


#Preview {
  MainCalendarView()
    .environment(HebrewCalendar())
    .frame(height: 700)
}

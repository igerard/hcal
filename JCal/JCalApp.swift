//
//  JCalApp.swift
//  JCal
//
//  SwiftUI application entry point. Replaces the former AppDelegate +
//  Main.storyboard + CalendarWindowController AppKit shell.
//

import SwiftUI

@main
struct JCalApp: App {
  @State private var hcal = HebrewCalendar()

  var body: some Scene {
    Window("JCal", id: "main") {
      MainCalendarView()
        .environment(hcal)
    }
    .commands {
      HolidayCommands(hcal: hcal)
      NavigationCommands(hcal: hcal)
    }
  }
}

/// The "Holidays" menu, mirroring the options previously wired in the storyboard.
struct HolidayCommands: Commands {
  @Bindable var hcal: HebrewCalendar

  var body: some Commands {
    CommandMenu("Holidays") {
      Picker("Calendar", selection: $hcal.calendarType) {
        Text("Gregorian").tag(CalendarType.gregorian)
        Text("Julian").tag(CalendarType.julian)
      }
      Picker("Area", selection: $hcal.holidayArea) {
        Text("Diaspora").tag(HolidayArea.diaspora)
        Text("Israel").tag(HolidayArea.israel)
      }

      Divider()

      Toggle("Parsha", isOn: $hcal.parchaActive)
      Toggle("Omer", isOn: $hcal.omerActive)
      Toggle("Chol Hamoed", isOn: $hcal.cholActive)

      Divider()

      Button("Reset") {
        hcal.holidayArea = .diaspora
        hcal.calendarType = .gregorian
        hcal.parchaActive = false
        hcal.omerActive = false
        hcal.cholActive = false
      }
    }
  }
}

/// Month/year navigation, replacing the former NSWindowController keyDown handling.
struct NavigationCommands: Commands {
  @Bindable var hcal: HebrewCalendar

  var body: some Commands {
    CommandMenu("Navigation") {
      Button("Previous Month") { hcal.decrementMonth() }
        .keyboardShortcut(.leftArrow, modifiers: [])
      Button("Next Month") { hcal.incrementMonth() }
        .keyboardShortcut(.rightArrow, modifiers: [])
      Button("Next Year") { hcal.year += 1 }
        .keyboardShortcut(.upArrow, modifiers: [])
      Button("Previous Year") { hcal.year -= 1 }
        .keyboardShortcut(.downArrow, modifiers: [])

      Divider()

      Button("Today") { hcal.toThisYearAndMonth() }
        .keyboardShortcut("t", modifiers: [.command])
    }
  }
}

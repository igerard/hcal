//
//  HebrewCalendar.swift
//  JCal
//
//  Created by Gerard Iglesias on 20/07/2019.
//  Renamed from HCal and migrated to the Observation framework.
//

import Foundation
import Observation

@Observable
final class HebrewCalendar {

  static var calendar = Calendar(identifier: .gregorian)

  // MARK: - Persistence helpers
  // Keep the JSON-encoded Data format used by the previous @UserDefault wrapper so
  // that preferences saved by earlier builds keep loading.
  private static func load<T: Codable>(_ key: String, default defaultValue: T) -> T {
    guard let data = UserDefaults.standard.data(forKey: key),
          let value = try? JSONDecoder().decode(T.self, from: data) else {
      return defaultValue
    }
    return value
  }

  private static func save<T: Codable>(_ value: T, forKey key: String) {
    UserDefaults.standard.set(try? JSONEncoder().encode(value), forKey: key)
  }

  // MARK: - Persisted preferences
  var holidayArea: HolidayArea {
    didSet { Self.save(holidayArea, forKey: "HolidayArea") }
  }

  var calendarType: CalendarType {
    didSet {
      // Keep the displayed day fixed across a calendar switch by converting through
      // the absolute (Rata Die) day number.
      switch oldValue {
      case .gregorian:
        let oldDate = SimpleDate(calendarType: .gregorian, year: year, month: month, day: day)
        let newDate = SimpleDate(calendarType: .julian, absolute: oldDate.absolute)
        year = newDate.year
        month = newDate.month
        day = newDate.day
      case .julian:
        let oldDate = SimpleDate(calendarType: .julian, year: year, month: month, day: day)
        let newDate = SimpleDate(calendarType: .gregorian, absolute: oldDate.absolute)
        year = newDate.year
        month = newDate.month
        day = newDate.day
      }
      Self.save(calendarType, forKey: "CalendarType")
    }
  }

  var parchaActive: Bool {
    didSet { Self.save(parchaActive, forKey: "ParchaActive") }
  }

  var omerActive: Bool {
    didSet { Self.save(omerActive, forKey: "OmerActive") }
  }

  var cholActive: Bool {
    didSet { Self.save(cholActive, forKey: "CholActive") }
  }

  var year: Int {
    didSet { Self.save(year, forKey: "ThisYear") }
  }

  var month: Int {
    didSet {
      if month < 1 { month = 1 }
      else if month > 12 { month = 12 }
      Self.save(month, forKey: "ThisMonth")
    }
  }

  var day: Int = 1

  init() {
    holidayArea = Self.load("HolidayArea", default: .diaspora)
    calendarType = Self.load("CalendarType", default: .gregorian)
    parchaActive = Self.load("ParchaActive", default: false)
    omerActive = Self.load("OmerActive", default: false)
    cholActive = Self.load("CholActive", default: false)
    year = Self.load("ThisYear", default: SimpleDate(calendarType: .gregorian, date: Date()).year)
    month = Self.load("ThisMonth", default: SimpleDate(calendarType: .gregorian, date: Date()).month)
  }

  // MARK: - Derived values
  var monthName: String {
    HebrewCalendar.calendar.locale = Locale.autoupdatingCurrent
    return HebrewCalendar.calendar.monthSymbols[Int(month - 1)]
  }

  enum HcalType {
    case gregorian
    case julian
  }
  var hCalType: HcalType = .gregorian

  var hebrewMonth: String {
    let hdate = SecularToHebrewConversion(year, month, day, hCalType == .julian)
    return String(cString: hdate.hebrew_month_name)
  }

  var hebrewYear: Int {
    let hdate = SecularToHebrewConversion(year, month, day, hCalType == .julian)
    return Int(hdate.year)
  }

  var hebrewMonths: String {
    let r = HebrewCalendar.calendar.range(
      of: .day,
      in: .month,
      for: HebrewCalendar.calendar.date(from:
        DateComponents(calendar: HebrewCalendar.calendar,
                       year: Int(year),
                       month: Int(month),
                       day: 1,
                       hour: 12))!)
    let hdatel = SecularToHebrewConversion(year, month, r!.lowerBound, hCalType == .julian)
    let hdateu = SecularToHebrewConversion(year, month, r!.upperBound - 1, hCalType == .julian)
    return "\(String(cString: hdatel.hebrew_month_name)) / \(String(cString: hdateu.hebrew_month_name))"
  }

  // MARK: - Navigation
  func incrementMonth() {
    if month == 12 {
      month = 1
      year += 1
    } else {
      month += 1
    }
  }

  func decrementMonth() {
    if month == 1 {
      month = 12
      year -= 1
    } else {
      month -= 1
    }
  }

  func thisYear() -> Int {
    SimpleDate(calendarType: calendarType, date: Date()).year
  }

  func thisMonth() -> Int {
    SimpleDate(calendarType: calendarType, date: Date()).month
  }

  func toThisYearAndMonth() {
    let date = SimpleDate(calendarType: calendarType, date: Date())
    year = date.year
    month = date.month
    day = 1
  }

  func today() -> SimpleDate {
    SimpleDate(calendarType: calendarType, date: Date())
  }

  func isToday(date: SimpleDate) -> Bool {
    let today = SimpleDate(calendarType: calendarType, date: Date())
    return date == today
  }
}

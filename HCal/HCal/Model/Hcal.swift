//
//  Hcal.swift
//  HCal
//
//  Created by Gerard Iglesias on 20/07/2019.
//

import Foundation


final class HCal  {
  public static var hcalModifiedName = Notification.Name("HcalModified")
  var hcalModifiedNotification: Notification {
    return Notification(name: HCal.hcalModifiedName, object: self, userInfo: nil)
  }
  
  static var calendar = Calendar(identifier: .gregorian)
  
  // prefs
  var holidayArea = UserDefault<HolidayArea>("HolidayArea", defaultValue: HolidayArea.diaspora) {
    didSet {
//      if oldValue != holidayArea {
        NotificationCenter.default.post(hcalModifiedNotification)
//      }
    }
  }
//  @UserDefault("CalendarType", defaultValue: CalendarType.gregorian)
  var calendarType = UserDefault<CalendarType>("CalendarType", defaultValue: CalendarType.gregorian) {
    didSet {
//      if oldValue == calendarType {
//        return
//      }
      switch oldValue.wrappedValue {
      case .gregorian:
        let oldDate = SimpleDate(calendarType: .gregorian, year: year.wrappedValue, month: month.wrappedValue, day: day)
        let newDate = SimpleDate(calendarType: .julian, absolute: oldDate.absolute)
        year <- newDate.year
        month <- newDate.month
        day = newDate.day
      case .julian:
        let oldDate = SimpleDate(calendarType: .julian, year: year.wrappedValue, month: month.wrappedValue, day: day)
        let newDate = SimpleDate(calendarType: .gregorian, absolute: oldDate.absolute)
        year <- newDate.year
        month <- newDate.month
        day = newDate.day
      }
      NotificationCenter.default.post(hcalModifiedNotification)
    }
  }

  var parchaActive = UserDefault<Bool>("ParchaActive", defaultValue: false) {
    didSet {
//      if oldValue != parchaActive {
        NotificationCenter.default.post(hcalModifiedNotification)
//      }
    }
  }

  var omerActive = UserDefault<Bool>("OmerActive", defaultValue: false) {
    didSet {
//      if oldValue != omerActive {
        NotificationCenter.default.post(hcalModifiedNotification)
//      }
    }
  }

  var cholActive = UserDefault<Bool>("CholActive", defaultValue: false) {
    didSet {
//      if oldValue != cholActive {
        NotificationCenter.default.post(hcalModifiedNotification)
//      }
    }
  }
  
  var year = UserDefault<Int>("ThisYear", defaultValue: SimpleDate(calendarType: .gregorian, date: Date()).year) {
    didSet {
//      if oldValue != year {
        NotificationCenter.default.post(hcalModifiedNotification)
//      }
    }
  }
  
  var month = UserDefault<Int>("ThisMonth", defaultValue: SimpleDate(calendarType: .gregorian, date: Date()).month) {
    didSet {
//      if oldValue == month {
//        return
//      }
      if month.wrappedValue < 1 {
        month <- 1
      }
      else if month.wrappedValue > 12 {
        month <- 12
      }
      NotificationCenter.default.post(hcalModifiedNotification)
    }
  }

  var day : Int = 1 {
    didSet {
//      if oldValue != day {
        NotificationCenter.default.post(hcalModifiedNotification)
//      }
    }
  }
  
  var monthName : String {
    HCal.calendar.locale = Locale.autoupdatingCurrent
    return HCal.calendar.monthSymbols[Int(month.wrappedValue-1)]
  }
    
  var hebrewMonth : String {
    get {
      let hdate = SecularToHebrewConversion(Int32(year.wrappedValue),
                                            Int32(month.wrappedValue),
                                            Int32(day),
                                            calendarType.wrappedValue == .julian)
      return String(cString: hdate.hebrew_month_name)
    }
  }
  var hebrewYear : Int {
    get {
      let hdate = SecularToHebrewConversion(Int32(year.wrappedValue),
                                            Int32(month.wrappedValue),
                                            Int32(day),
                                            calendarType.wrappedValue == .julian)
      return Int(hdate.year)
    }
  }
  
  var hebrewMonths : String {
    get {
      let r = HCal.calendar.range(of: .day,
                                  in: .month,
                                  for: HCal.calendar.date(from:
                                    DateComponents(calendar: HCal.calendar,
                                                   year: Int(year.wrappedValue),
                                                   month: Int(month.wrappedValue),
                                                   day: 1,
                                                   hour: 12))!)
      let hdatel = SecularToHebrewConversion(Int32(year.wrappedValue),
                                             Int32(month.wrappedValue),
                                             Int32(r!.lowerBound),
                                             calendarType.wrappedValue == .julian)
      let hdateu = SecularToHebrewConversion(Int32(year.wrappedValue),
                                             Int32(month.wrappedValue),
                                             Int32(r!.upperBound-1),
                                             calendarType.wrappedValue == .julian)
      return "\(String(cString: hdatel.hebrew_month_name)) / \(String(cString: hdateu.hebrew_month_name))"
    }
  }
  
  func incrementMonth() {
    if month == 12 {
      month <- 1
      year.wrappedValue += 1
    }
    else {
      month.wrappedValue += 1
    }
  }
  
  func decrementMonth() {
    if month == 1 {
      month <- 12
      year.wrappedValue -= 1
    }
    else {
      month.wrappedValue -= 1
    }
  }
  
  func thisYear() -> Int {
    return SimpleDate(calendarType: calendarType.wrappedValue, date: Date()).year
  }
  
  func thisMonth() -> Int {
    return SimpleDate(calendarType: calendarType.wrappedValue, date: Date()).month
  }
  
  func toThisYearAndMonth() {
    let date = SimpleDate(calendarType: calendarType.wrappedValue, date: Date())
    year <- date.year
    month <- date.month
    day = 1
  }
  
  func today() -> SimpleDate {
    return SimpleDate(calendarType: self.calendarType.wrappedValue, date: Date())
  }
  
  func isToday(date: SimpleDate) -> Bool {
    let today = SimpleDate(calendarType: calendarType.wrappedValue, date: Date())
    return date == today
  }
  
}

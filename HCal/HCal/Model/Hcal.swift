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
    Notification(name: HCal.hcalModifiedName, object: self, userInfo: nil)
  }
  
  static var calendar = Calendar(identifier: .gregorian)
  
  // prefs
  @UserDefault("HolidayArea", defaultValue: HolidayArea.diaspora)
  var holidayArea : HolidayArea {
    didSet {
      if oldValue != holidayArea {NotificationCenter.default.post(hcalModifiedNotification)}
    }
  }
  @UserDefault("CalendarType", defaultValue: CalendarType.gregorian)
  var calendarType : CalendarType {
    didSet {
      if oldValue == calendarType {return}
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
      NotificationCenter.default.post(hcalModifiedNotification)
    }
  }
  @UserDefault("ParchaActive", defaultValue: false)
  var parchaActive : Bool {
    didSet {
      if oldValue != parchaActive {NotificationCenter.default.post(hcalModifiedNotification)}
    }
  }
  @UserDefault("OmerActive", defaultValue: false)
  var omerActive : Bool {
    didSet {
      if oldValue != omerActive {NotificationCenter.default.post(hcalModifiedNotification)}
    }
  }
  @UserDefault("CholActive", defaultValue: false)
  var cholActive : Bool {
    didSet {
      if oldValue != cholActive {NotificationCenter.default.post(hcalModifiedNotification)}
    }
  }
  
  @UserDefault("ThisYear", defaultValue: SimpleDate(calendarType: .gregorian, date: Date()).year)
  var year : Int {
    didSet {
      if oldValue != year {NotificationCenter.default.post(hcalModifiedNotification)}
    }
  }
  
  @UserDefault("ThisMonth", defaultValue: SimpleDate(calendarType: .gregorian, date: Date()).month)
  var month : Int {
    didSet {
      if oldValue == month {return}
      if month < 1 {
        month = 1
      }
      else if month > 12 {
        month = 12
      }
      NotificationCenter.default.post(hcalModifiedNotification)
    }
  }
  var day : Int = 1 {
    didSet {
      if oldValue != day {NotificationCenter.default.post(hcalModifiedNotification)}
    }
  }
  
  var monthName : String {
    HCal.calendar.locale = Locale.autoupdatingCurrent
    return HCal.calendar.monthSymbols[Int(month-1)]
  }
  
  enum HcalType {
    case gregorian
    case julian
  }
  var hCalType : HcalType = .gregorian {
    didSet {
      if oldValue != hCalType {NotificationCenter.default.post(hcalModifiedNotification)}
    }
  }
  var israelHoliday : Bool = false {
    didSet {
      if oldValue != israelHoliday {NotificationCenter.default.post(hcalModifiedNotification)}
    }
  }
  
  var hebrewMonth : String {
    get {
      let hdate = SecularToHebrewConversion(Int32(year),
                                            Int32(month),
                                            Int32(day),
                                            hCalType == .julian)
      return String(cString: hdate.hebrew_month_name)
    }
  }
  var hebrewYear : Int {
    get {
      let hdate = SecularToHebrewConversion(Int32(year),
                                            Int32(month),
                                            Int32(day),
                                            hCalType == .julian)
      return Int(hdate.year)
    }
  }
  
  var hebrewMonths : String {
    get {
      let r = HCal.calendar.range(of: .day,
                                  in: .month,
                                  for: HCal.calendar.date(from:
                                    DateComponents(calendar: HCal.calendar,
                                                   year: Int(year),
                                                   month: Int(month),
                                                   day: 1,
                                                   hour: 12))!)
      let hdatel = SecularToHebrewConversion(Int32(year),
                                             Int32(month),
                                             Int32(r!.lowerBound),
                                             hCalType == .julian)
      let hdateu = SecularToHebrewConversion(Int32(year),
                                             Int32(month),
                                             Int32(r!.upperBound-1),
                                             hCalType == .julian)
      return "\(String(cString: hdatel.hebrew_month_name)) / \(String(cString: hdateu.hebrew_month_name))"
    }
  }
  
  func incrementMonth() {
    if month == 12 {
      month = 1
      year += 1
    }
    else {
      month += 1
    }
  }
  
  func decrementMonth() {
    if month == 1 {
      month = 12
      year -= 1
    }
    else {
      month -= 1
    }
  }
  
  func thisYear() -> Int {
    return SimpleDate(calendarType: calendarType, date: Date()).year
  }
  
  func thisMonth() -> Int {
    return SimpleDate(calendarType: calendarType, date: Date()).month
  }
  
  func toThisYearAndMonth() {
    let date = SimpleDate(calendarType: calendarType, date: Date())
    year = date.year
    month = date.month
    day = 1
  }
  
  func today() -> SimpleDate {
    return SimpleDate(calendarType: self.calendarType, date: Date())
  }
  
  func isToday(date: SimpleDate) -> Bool {
    let today = SimpleDate(calendarType: calendarType, date: Date())
    return date == today
  }
  
}

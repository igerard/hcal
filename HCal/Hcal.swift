//
//  Hcal.swift
//  HCal
//
//  Created by Gerard Iglesias on 20/07/2019.
//

import SwiftUI
import Combine

final class HCal : ObservableObject {
  
  static var calendar = Calendar(identifier: .gregorian)
  
  @Published var year : Int = thisYear() ?? 2000
  @Published var month : Int = thisMonth() ?? 1 {
    didSet {
      if month < 1 {
        month = 1
      }
      else if month > 12 {
        month = 12
      }
    }
  }
  @Published var day : Int = HCal.calendar.dateComponents([.day], from: Date()).day ?? 1
  
  var monthName : String {
    HCal.calendar.locale = Locale.autoupdatingCurrent
    return HCal.calendar.monthSymbols[month-1]
  }
  
  enum HcalType {
    case gregorian
    case julian
  }
  @Published var hCalType : HcalType = .gregorian
  @Published var israelHoliday : Bool = false
  
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
                                                   year: year,
                                                   month: month,
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

  func today() {
    year = HCal.thisYear() ?? 2000
    month = HCal.thisMonth() ?? 1
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
  
  static func thisYear() -> Int? {
      return HCal.calendar.dateComponents([.year], from: Date()).year
    }
    
    static func thisMonth() -> Int? {
      return HCal.calendar.dateComponents([.month], from: Date()).month
    }
    
    static func isToday(date: Date) -> Bool {
      HCal.calendar.dateComponents([.year, .month, .day], from: date) == HCal.calendar.dateComponents([.year, .month, .day], from: Date())
    }
    
}

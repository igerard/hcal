//
//  GridDateGenerator.swift
//  HCal
//
//  Created by Gerard Iglesias on 03/08/2019.
//

import Foundation

final class GridDateGenerator {
  let date : SimpleDate
  // what day start the week ? 1 for Sunday
  let firstDay : Int
  let calendar = Locale.current.calendar
  let dayIndex : Int
  
  init?(firstDay: Int, cType: CalendarType, year: Int, month: Int) {
    self.firstDay = firstDay
    date = SimpleDate(calendarType: cType, year: year, month: month, day: 1)
    self.dayIndex = (date.weekday - firstDay) % 7
  }
  
  func dateAt(_ i : Int, _ j : Int) -> SimpleDate? {
    guard (0..<7).contains(j) else {
      return nil
    }
    return SimpleDate(calendarType: date.type, absolute:date.absolute + 7*i+j - dayIndex)
  }
  
  func format(date: SimpleDate) -> String {
    let dash = "-"
    let emptyString = ""
    return "\(calendar.weekdaySymbols[date.weekday-1]) \(date.day) \(calendar.monthSymbols[date.month-1]) \(date.year) \(date.month == self.date.month ? dash : emptyString)"
  }
}

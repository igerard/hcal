//
//  GridDateGenerator.swift
//  HCal
//
//  Created by Gerard Iglesias on 03/08/2019.
//

import Foundation

final class GridDateGenerator {
  let firstDay : Int
  let year : Int
  let month : Int
  let calendar = Locale.current.calendar
  let date : Date
  let dayIndex : Int
  
  init?(firstDay: Int, year: Int, month: Int) {
    self.firstDay = firstDay
    self.year = year
    self.month = month
    let comps = DateComponents(calendar: calendar, year: year, month: month, day: 1, hour: 12)
    if let d = self.calendar.date(from: comps) {
      self.date = d
    } else {
      return nil
    }
    self.dayIndex = ((calendar.component(.weekday, from: self.date) - firstDay) + 7) % 7
  }
  
  func dateAt(_ i : Int, _ j : Int) -> Date? {
    guard (0..<7).contains(j) else {
      return nil
    }
    return calendar.date(byAdding: .day, value: 7*i+j - dayIndex, to: date)
  }
  
  func format(date: Date) -> String {
    let dash = "-"
    let emptyString = ""
    let comps = calendar.dateComponents([.day, .month, .year, .weekday], from: date)
    return "\(calendar.weekdaySymbols[comps.weekday!-1]) \(comps.day!) \(calendar.monthSymbols[comps.month!-1]) \(comps.year!) \(comps.month == month ? dash : emptyString)"
  }
}

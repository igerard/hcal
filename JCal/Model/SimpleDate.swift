//
//  SimpleDate.swift
//  JCal
//
//  Created by Gerard Iglesias on 11/09/2019.
//  Copyright © 2019 Gerard Iglesias. All rights reserved.
//

import Foundation

// basic date modelisation to return gregorian or julian date
struct SimpleDate : Equatable {
  let type:      CalendarType;
  let year:      Int;
  let month:     Int;
  let day:       Int;
  let absolute:  Int;
  
  init(calendarType: CalendarType, year: Int, month: Int, day: Int) {
    self.type = calendarType
    self.year = year
    self.month = month
    self.day = day
    switch calendarType {
    case .gregorian:
      absolute = absolute_from_gregorian(year, month, day)
    case .julian:
      absolute = absolute_from_julian(year, month, day)
    }
  }
  
  init(calendarType: CalendarType, date: Date) {
    let comps = HebrewCalendar.calendar.dateComponents([.year, .month, .day], from: date)
    absolute = absolute_from_gregorian(comps.year!, comps.month!, comps.day!)
    switch calendarType {
    case .gregorian:
      type = .gregorian
      year = comps.year!
      month = comps.month!
      day = comps.day!
    case .julian:
      var year : Int = 0
      var month : Int = 0
      var day : Int = 0
      julian_from_absolute(absolute, &year, &month, &day)
      type = .julian
      self.year = year
      self.month = month
      self.day = day
    }
  }
  
  init(calendarType: CalendarType, absolute: Int) {
    self.type = calendarType
    self.absolute = absolute
    var year : Int = 0
    var month : Int = 0
    var day : Int = 0
    switch calendarType {
    case .gregorian:
      gregorian_from_absolute(absolute, &year, &month, &day)
    case .julian:
      julian_from_absolute(absolute, &year, &month, &day)
    }
    self.year = year
    self.month = month
    self.day = day
  }
  
  var weekday: Int {
    return absolute % 7 + 1
  }
}

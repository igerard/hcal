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
      absolute = absolute_from_gregorian(Int32(year), Int32(month), Int32(day))
    case .julian:
      absolute = absolute_from_julian(Int32(year), Int32(month), Int32(day))
    }
  }
  
  init(calendarType: CalendarType, date: Date) {
    let comps = HCal.calendar.dateComponents([.year, .month, .day], from: date)
    absolute = absolute_from_gregorian(Int32(comps.year!), Int32(comps.month!), Int32(comps.day!))
    switch calendarType {
    case .gregorian:
      type = .gregorian
      year = comps.year!
      month = comps.month!
      day = comps.day!
    case .julian:
      var year : Int32 = 0
      var month : Int32 = 0
      var day : Int32 = 0
      julian_from_absolute(absolute, &year, &month, &day)
      type = .julian
      self.year = Int(year)
      self.month = Int(month)
      self.day = Int(day)
    }
  }
  
  init(calendarType: CalendarType, absolute: Int) {
    self.type = calendarType
    self.absolute = absolute
    var year : Int32 = 0
    var month : Int32 = 0
    var day : Int32 = 0
    switch calendarType {
    case .gregorian:
      gregorian_from_absolute(absolute, &year, &month, &day)
    case .julian:
      julian_from_absolute(absolute, &year, &month, &day)
    }
    self.year = Int(year)
    self.month = Int(month)
    self.day = Int(day)
  }
  
  var weekday: Int {
    return absolute % 7 + 1
  }
}

//
//  CalendarType.swift
//  HCal
//
//  Created by Gerard Iglesias on 11/08/2019.
//

import Foundation

enum CalendarType: String, CaseIterable, Codable {
  case gregorian = "Gregorian"
  case julian = "Julian"
}

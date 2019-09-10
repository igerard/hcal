//
//  ThemeSupport.swift
//  HCal
//
//  Created by Gerard Iglesias on 05/08/2019.
//

import SwiftUI

final class Theming {

  static func opacityLevel(_ isActive: Bool) -> Double {
    return isActive ? 1.0 : 0.33
  }
  
  static func dayDiskColor(theme: ColorScheme, isActive: Bool) -> Color {
    switch theme {
    case .dark:
      return Color(red: 1.0, green: 47.0/255.0, blue: 146.0/255.0)
        .opacity(opacityLevel(isActive))
    case .light:
      return Color(red: 0, green: 150.0/255.0, blue: 1.0)
        .opacity(opacityLevel(isActive))
    default:
      return Color.gray
    }
  }

  static func dayTextColor(theme: ColorScheme, isActive: Bool) -> Color {
    switch theme {
    case .dark:
      return Color(red: 1.0, green: 1.0, blue: 1.0)
        .opacity(opacityLevel(isActive))
    case .light:
      return Color(red: 0.0, green: 0.0, blue: 0.0)
        .opacity(opacityLevel(isActive))
    default:
      return Color.gray
        .opacity(opacityLevel(isActive))
    }
  }

  static func holidayTextColor(theme: ColorScheme, isActive: Bool) -> Color {
    switch theme {
    case .dark:
      return salmon.opacity(opacityLevel(isActive))
    case .light:
      return maraschino.opacity(opacityLevel(isActive))
    default:
      return Color.gray
        .opacity(opacityLevel(isActive))
    }
  }

  static func dayBackgroundColor(theme: ColorScheme, accentFlag: Bool) -> Color {
    switch theme {
    case .light:
      return accentFlag ? Theming.lightGray : Color.white
    case .dark:
      return accentFlag ? Theming.darkGray : Color(white: 0.13)
    default:
      return Color.gray
    }
  }
  
  static let paleBlue = Color(red: 240.0/255.0, green: 250.0/255.0, blue: 250.0/255.0)
  static let maraschino = Color(red: 255.0/255.0, green: 38.0/255.0, blue: 0.0/255.0)
  static let salmon = Color(red: 255.0/255.0, green: 126.0/255.0, blue: 121.0/255.0)
  static let lightGray = Color(white: 0.95)
  static let darkGray = Color(white: 0.05)
}

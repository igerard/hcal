//
//  MonthSelector.swift
//  HCal
//
//  Created by Gerard Iglesias on 19/07/2019.
//

import SwiftUI

struct MonthSelector : View {
  @Environment(\.colorScheme) var theme
  @Environment(HebrewCalendar.self) private var hcal

  func formattedYear(year: Int) -> String {
    return String(format: "%d", year)
  }
  
  var body: some View {

    HStack(alignment: .center, spacing: 16) {
      VStack(alignment: .leading, spacing: 0) {
        Text("\(hcal.monthName) \(formattedYear(year: hcal.year))")
          .font(.largeTitle.weight(.semibold))
          .allowsTightening(true)
        Text("\(hcal.hebrewMonths) \(formattedYear(year: hcal.hebrewYear))")
          .font(.title3)
          .foregroundStyle(.secondary)
          .allowsTightening(true)
      }

      Spacer(minLength: 16)

      HStack(spacing: 8) {
        Button {
          hcal.decrementMonth()
        } label: {
          Image(systemName: "chevron.left")
        }
        .help("Previous Month")
        .focusable(false)

        Button {
          hcal.toThisYearAndMonth()
        } label: {
          Image(systemName: "calendar")
        }
        .help("Today")
        .focusable(false)

        Button {
          hcal.incrementMonth()
        } label: {
          Image(systemName: "chevron.right")
        }
        .help("Next Month")
        .focusable(false)
      }
      .buttonStyle(.bordered)
      .controlSize(.large)
      .font(.title3)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 8)
    .fixedSize(horizontal: false, vertical: true)
  }
}

#Preview {
  MonthSelector()
    .environment(HebrewCalendar())
    .frame(minWidth: 830)
}

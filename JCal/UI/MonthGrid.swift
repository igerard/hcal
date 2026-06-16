//
//  MonthGrid.swift
//  HCal
//
//  Created by Gerard Iglesias on 19/07/2019.
//

import SwiftUI

struct MonthGrid : View {
  @Environment(\.colorScheme) var theme
  @Environment(HebrewCalendar.self) private var hcal
  private let weekDaysLetter = HebrewCalendar.calendar.weekdaySymbols.map { $0.prefix(1) }

  var body: some View {
    let nbRows = 6
    let nbColumns = 7
    let generator = GridDateGenerator(firstDay: 1, cType: hcal.calendarType, year: hcal.year, month: hcal.month)

    // Native, equally-distributed layout: each cell uses .infinity frames so the
    // grid resizes cleanly with the window. The 1pt spacing over a gray background
    // renders as the grid lines.
    VStack(spacing: 1) {
      HStack(spacing: 1) {
        ForEach(0..<nbColumns, id: \.self) { dayIndex in
          Text(weekDaysLetter[dayIndex])
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
        }
      }
      .padding([.top, .bottom], 2)
      .frame(height: 20)

      ForEach(0..<nbRows, id: \.self) { i in
        HStack(spacing: 1) {
          ForEach(0..<nbColumns, id: \.self) { j in
            DayView(date: generator.dateAt(i, j) ?? SimpleDate(calendarType: hcal.calendarType, absolute: 0))
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          }
        }
      }
    }
    .background(theme == .light ? Color(white: 0.84) : Color(white: 0.26))
  }
}

#Preview {
  MonthGrid()
    .environment(HebrewCalendar())
    .frame(width: 900, height: 700)
}

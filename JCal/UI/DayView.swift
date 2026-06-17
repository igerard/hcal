//
//  DayView.swift
//  HCal
//
//  Created by Gerard Iglesias on 12/07/2019.
//

import SwiftUI

extension Text {
  func hcalDayTextStyle(theme: ColorScheme, isActive: Bool) -> Self {
    return self
      .foregroundColor(Theming.dayTextColor(theme: theme, isActive: isActive))
  }
  func hcalHolidayTextStyle(theme: ColorScheme, isActive: Bool) -> Self {
    return self
      .foregroundColor(Theming.holidayTextColor(theme: theme, isActive: isActive))

  }
}

struct DayView : View {
  @Environment(\.colorScheme) var theme
  @Environment(HebrewCalendar.self) private var hcal
  let date : SimpleDate
  @State private var showExplanation = false

  var body: some View {
    let inMonth = date.month == hcal.month
    let isToday = hcal.isToday(date: date)
    let isShabbat = date.weekday == 7
    ParshaP = hcal.parchaActive
    OmerP = hcal.omerActive
    CholP = hcal.cholActive
    let hdate = SecularToHebrewConversion(date.year,
                                          date.month,
                                          date.day,
                                          hcal.calendarType == .julian)
    let holiday = FindHoliday(Int32(hdate.month),
                              Int32(hdate.day),
                              Int32(hdate.day_of_week),
                              Int32(hdate.kvia),
                              hdate.hebrew_leap_year_p,
                              hcal.holidayArea == .israel,
                              Int32(hdate.hebrew_day_number),
                              Int32(hdate.year))
    let hasEvent = holiday?.pointee != nil
    var holidayNames: [String] = []
    if let base = holiday {
      for i in 0..<5 {                     // FindHoliday returns up to 5 slots
        guard let cstr = base.advanced(by: i).pointee else { break }
        holidayNames.append(String(cString: cstr))
      }
    }
    return VStack {
      HStack {
        Spacer()
        DayNumber(value: date.day, isActive: inMonth, visibleDisk: isToday)
      }
      .padding([.trailing], 5)
      .padding([.top], 2)

      HStack {
        Text("\(hdate.day)")
          .hcalDayTextStyle(theme: theme, isActive: inMonth)
        Text(String(cString: hdate.hebrew_month_name))
          .hcalDayTextStyle(theme: theme, isActive: inMonth)
        Spacer()
      }
      .padding([.leading], 5)
      .font(.subheadline)

      Spacer()
            
      VStack {
        ForEach(Array(holidayNames.prefix(2).enumerated()), id: \.offset) { _, name in
          HStack {
            Text(name)
              .foregroundStyle(Theming.holidayCategoryColor(HolidayInfo.category(for: name))
                .opacity(Theming.opacityLevel(inMonth)))
              .font(Font.caption.italic())
            Spacer()
          }
          .padding([.bottom, .leading], 2)
        }
      }
     .padding([.bottom, .leading], 5)
    }
//    .frame(minWidth: 120, minHeight: 100, alignment: .center)
    .background(Theming.dayBackgroundColor(theme: theme, accentFlag: isShabbat))
    .contentShape(Rectangle())
    .onTapGesture {
      if hasEvent { showExplanation = true }
    }
    .popover(isPresented: $showExplanation, arrowEdge: .trailing) {
      DayExplanationView(date: date)
        .environment(hcal)
    }
  }
}

#Preview {
  let hcal: HebrewCalendar = {
    let h = HebrewCalendar()
    h.year = 2026
    h.month = 9
    return h
  }()

  Group {
    DayView(date: SimpleDate(calendarType: .gregorian,
                             year: 2026, month: 9, day: 5))
      .environment(hcal)
      .frame(width: 120, height: 100)

    DayView(date: SimpleDate(calendarType: .gregorian,
                             year: 2020, month: 11, day: 13))
      .environment(hcal)
      .frame(width: 120, height: 100)

    DayView(date: SimpleDate(calendarType: .gregorian,
                             year: 2020, month: 11, day: 30))
      .environment(hcal)
      .frame(width: 120, height: 100)
  }
}

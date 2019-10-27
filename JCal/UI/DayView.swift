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
  @EnvironmentObject var hcal: HCal
  let date : SimpleDate
  
  var body: some View {
    let inMonth = date.month == hcal.month
    let isToday = hcal.isToday(date: date)
    let isShabbat = date.weekday == 7
    ParshaP = hcal.parchaActive
    OmerP = hcal.omerActive
    CholP = hcal.cholActive
    let hdate = SecularToHebrewConversion(Int32(date.year),
                                          Int32(date.month),
                                          Int32(date.day),
                                          hcal.calendarType == .julian)
    let holiday = FindHoliday(hdate.month,
                              hdate.day,
                              hdate.day_of_week,
                              hdate.kvia,
                              hdate.hebrew_leap_year_p,
                              hcal.holidayArea == .israel,
                              hdate.hebrew_day_number,
                              hdate.year)
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

//      VStack{
        holiday?.pointee.flatMap{p in
          HStack {
            Text(String(cString: p))
              .hcalHolidayTextStyle(theme: theme, isActive: inMonth)
              .font(Font.caption.italic())
            Spacer()
          }
          .padding([.bottom, .leading], 5)
        }
        (holiday?.advanced(by: 1).pointee).flatMap{p in
          HStack {
            Text(String(cString: p))
              .hcalHolidayTextStyle(theme: theme, isActive: inMonth)
              .font(Font.caption.italic())
            Spacer()
          }
          .padding([.bottom, .leading], 5)
        }
//      }
//     .padding([.bottom, .leading], 5)
    }
    .background(Theming.dayBackgroundColor(theme: theme, accentFlag: isShabbat))
    .foregroundColor(Color.red)
  }
}

#if DEBUG
var hcal : HCal = {
  let h = HCal()
  h.year = 2010
  h.month = 4
  return h
}()

struct DayView_Previews : PreviewProvider {
  static var previews: some View {
    DayView(date: SimpleDate(calendarType: .gregorian,
                             year: 2020, month: 4, day: 16))
                .environmentObject(hcal)
      .frame(width: 100, height: 90)
  }
}
#endif

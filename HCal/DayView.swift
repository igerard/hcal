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
  let date : Date
  let fontSize = Font.subheadline
  
  var body: some View {
    let comps = HCal.calendar.dateComponents([.month, .year, .day], from: date)
    let inMonth = comps.month == hcal.month
    let isToday = comps == HCal.calendar.dateComponents([.year, .month, .day], from: Date())
    let isShabbat = HCal.calendar.dateComponents([.weekday], from: date).weekday == .some(7)
    let hdate = SecularToHebrewConversion(Int32(comps.year!),
                                          Int32(comps.month!),
                                          Int32(comps.day!),
                                          false)
    let holiday = FindHoliday(hdate.month,
                              hdate.day,
                              hdate.day_of_week,
                              hdate.kvia,
                              hdate.hebrew_leap_year_p,
                              false,
                              hdate.hebrew_day_number,
                              hdate.year)
        
    return VStack {
      HStack {
        Spacer()
        DayNumber(value: comps.day!, isActive: inMonth, visibleDisk: isToday)
      }
      .padding([.top, .trailing], 5)

      HStack {
        Text("\(hdate.day)")
          .hcalDayTextStyle(theme: theme, isActive: inMonth)
        Text(String(cString: hdate.hebrew_month_name))
          .hcalDayTextStyle(theme: theme, isActive: inMonth)
        Spacer()
      }
      .padding([.bottom, .leading], 10)
      .font(.subheadline)

      Spacer()

      VStack{
        holiday?.pointee.flatMap{p in
          HStack {
            Text(String(cString: p))
              .hcalHolidayTextStyle(theme: theme, isActive: inMonth)
              .font(Font.caption.italic())
            Spacer()
          }
        }
        (holiday?.advanced(by: 1).pointee).flatMap{p in
          HStack {
            Text(String(cString: p))
              .hcalHolidayTextStyle(theme: theme, isActive: inMonth)
              .font(Font.caption.italic())
            Spacer()
          }
        }
      }
      .padding([.bottom, .leading], 10)
    }
    .frame(minWidth: 100,
           idealWidth: 200,
           maxWidth: 1000,
           minHeight: 80,
           idealHeight: 160,
           maxHeight: 1000,
           alignment: .center)
      .background(Theming.dayBackgroundColor(theme: theme,
                                             accentFlag: isShabbat))
      .padding(0)
      .foregroundColor(Color.red)
//      .opacity(inMonth ? 1.0 : 0.2)
//      .font(.system(size: 12))
//      .foregroundColor(theme == .light ? Color.black : Color.white)
  }
}

#if DEBUG
struct DayView_Previews : PreviewProvider {
  static let hcal = HCal()
  static var previews: some View {
//    VStack(alignment: .center, spacing: 1) {
//
//      HStack(alignment: .center, spacing: 1) {
//        ForEach((0..<5), id: \.self) {dayIndex in
//          HStack{
//            Spacer()
//            Text("\(dayIndex)")
//              .fontWeight(.bold)
//            Spacer()
//          }
//        }
//      }.frame(width: nil, height: nil, alignment: .center)
//
//      ForEach(0 ..< 5) { item in
//        HStack(alignment: .center, spacing: 1) {
//          ForEach(/*@START_MENU_TOKEN@*/0 ..< 5/*@END_MENU_TOKEN@*/) { item in
//            VStack(alignment: .center, spacing: 1) {
    DayView(date: Date().addingTimeInterval(00000))
                //.frame(width: 120, height: 120, alignment: .leading)
                .environmentObject(hcal)
//            }
//          }
//        }
//      }
//    }
//    .frame(width: 620, height: 820, alignment: .leading)
  }
}
#endif

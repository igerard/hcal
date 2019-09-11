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
  let fontSize = Font.subheadline
  
  var body: some View {
    let inMonth = date.month == hcal.month
    let isToday = hcal.isToday(date: date)
    let isShabbat = date.weekday == 7
    ParshaP = hcal.parchaActive
    OmerP = hcal.omerActive
    CholP = hcal.cholActive
    let goodHeight : CGFloat = (hcal.parchaActive || hcal.omerActive || hcal.cholActive ? 40.0 : 30.0)
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
    .frame(minWidth: 120,
           idealWidth: 120,
           maxWidth: 200,
           minHeight: goodHeight,
           idealHeight: goodHeight,
           maxHeight: 200,
           alignment: .center)
      .background(Theming.dayBackgroundColor(theme: theme,
                                             accentFlag: isShabbat))
      .padding(0)
      .foregroundColor(Color.red)
//      .onTapGesture {
//        let hc = Calendar(identifier: .hebrew)
//        let hd = hc.dateComponents([.year,.month,.day,.weekday,.weekOfMonth], from: self.date)
//        print("\(hd.day!) \(hc.weekdaySymbols[hd.weekday!-1]) - \(hc.monthSymbols[hd.month!-1]) - \(hd.year!)")
//
//        var gc = Calendar(identifier: .gregorian)
//        gc.locale = Locale.autoupdatingCurrent
//        let gd = gc.dateComponents([.year,.month,.day,.weekday,.weekOfMonth], from: self.date)
//        print("\(gd.day!) \(gc.weekdaySymbols[gd.weekday!-1]) - \(gc.monthSymbols[gd.month!-1]) - \(gd.year!)")
//    }
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
    DayView(date: SimpleDate(calendarType: .gregorian, date: Date().addingTimeInterval(00000)))
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

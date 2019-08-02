//
//  DayView.swift
//  HCal
//
//  Created by Gerard Iglesias on 12/07/2019.
//

import SwiftUI

struct DayView : View {
  @Environment(\.colorScheme) var theme
  let calendar = Calendar(identifier: .gregorian)
  let date : Date
  
  var body: some View {
    let comps = calendar.dateComponents([.month, .year, .day], from: date)
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
        Text (
          "\(comps.day!)"
        )
          .bold()
      }
      .padding([.trailing, .top], 5)
      HStack {
        Text(
          "\(hdate.day)"
        )
        Text(
          String(cString: hdate.hebrew_month_name)
        )
        Spacer()
      }.padding([.bottom, .leading], 10)
      Spacer()
      VStack{
        holiday?.pointee.flatMap{p in
          HStack {
            Text(String(cString: p))
            Spacer()
          }
        }
        (holiday?.advanced(by: 1).pointee).flatMap{p in
          HStack {
            Text(String(cString: p))
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
      .background(theme == .light
        ? Color.white
        : Color.init(white: 0.13))
      .padding(0)
      .font(.system(size: 12))
      .foregroundColor(theme == .light ? Color.black : Color.white)
  }
}

#if DEBUG
struct DayView_Previews : PreviewProvider {
  static var previews: some View {
    DayView(date: Date()).frame(width: 120, height: 120, alignment: .leading)
  }
}
#endif

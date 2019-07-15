//
//  DayView.swift
//  HCal
//
//  Created by Gerard Iglesias on 12/07/2019.
//

import SwiftUI

struct DayView : View {
  let calendar = Calendar(identifier: .gregorian)
  @Binding var date : Date
  
  var body: some View {
    let comps = calendar.dateComponents([.month, .year, .day], from: $date.value)
    let hdate = SecularToHebrewConversion(Int32(comps.year!),
                                          Int32(comps.month!),
                                          Int32(comps.day!),
                                          true)
    print(date.debugDescription)
    
    return VStack {
      HStack(alignment: .center, spacing: 10) {
        Text(
          "\(hdate.day)"
        )
        Text(
          String(cString: hdate.secular_month_name,
                 encoding: .utf8)
            ?? "error"
        )
      }
      HStack(alignment: .center, spacing: 10) {
        Text(
          "\(hdate.hebrew_day_number)"
        )
        Text(
          String(cString: hdate.hebrew_month_name,
                 encoding: .utf8)
            ?? "error"
        )
        Text(
          "(\(hdate.hebrew_month_length))"
        )
      }
    }
  }
}

#if DEBUG
struct DayView_Previews : PreviewProvider {
  static var previews: some View {
    DayView(date: .constant(Date()))
  }
}
#endif

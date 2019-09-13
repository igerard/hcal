//
//  DayNumber.swift
//  HCal
//
//  Created by Gerard Iglesias on 04/08/2019.
//

import SwiftUI

struct DayNumber: View {
  @Environment(\.colorScheme) var theme
  let value: Int
  let isActive: Bool
  let visibleDisk: Bool
  
  var body: some View {
    ZStack {
      if visibleDisk {
        Capsule(style: .circular)
          .frame(width: 26, height: 26, alignment: .center)
          .foregroundColor(Theming.dayDiskColor(theme: theme, isActive: isActive))
      }
      Text ("\(value)")
        .font(.headline)
        .bold()
        .hcalDayTextStyle(theme: theme, isActive: isActive)
    }
  }
}

#if DEBUG
struct DayNumber_Previews: PreviewProvider {
  static var previews: some View {
    DayNumber(value: 31,
              isActive: false,
              visibleDisk: true)
  }
}
#endif

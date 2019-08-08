//
//  MonthGrid.swift
//  HCal
//
//  Created by Gerard Iglesias on 19/07/2019.
//

import SwiftUI

struct MonthGrid : View {
  @Environment(\.colorScheme) var theme
  @EnvironmentObject var hcal: HCal
  private let weekDaysLetter = HCal.calendar.weekdaySymbols.map{$0.prefix(1)}
  
  var body: some View {

    let generator = GridDateGenerator(firstDay: 1, year: hcal.year, month: hcal.month)

    return VStack(alignment: .center, spacing: 1){
      
      HStack(alignment: .center, spacing: 1) {
        ForEach((0...6), id: \.self) {dayIndex in
          HStack{
            Spacer()
            Text(self.weekDaysLetter[dayIndex]).fontWeight(.bold)
            Spacer()
          }
        }
      }
      .background(theme == .light ? Color(white: 0.84) : Color(white: 0.26))
      .padding([.top, .bottom], 2)
      .frame(width: nil, height: 20, alignment: .center)
      
      HStack(alignment: .center, spacing: 1){
        ForEach((0...6), id: \.self) {j in
          VStack(alignment: .center, spacing: 1) {
            ForEach((0...5), id: \.self){i in
              DayView(date: generator?.dateAt(i, j) ?? Date())
            }
          }
        }
      }
      .background(theme == .light ? Color(white: 0.84) : Color(white: 0.26))
    }
    .background(theme == .light ? Color(white: 0.84) : Color(white: 0.26))
  }
}

#if DEBUG
struct MonthGrid_Previews : PreviewProvider {
  static var previews: some View {
    MonthGrid().environmentObject(HCal())
      .frame(width: nil, height: 800, alignment: .center)
  }
}
#endif

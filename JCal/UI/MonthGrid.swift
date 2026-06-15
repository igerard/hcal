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
    let nbRows = 6
    let nbColumns = 7
    let spacing = 1
    let minWidth = CGFloat(nbColumns * 120 + (nbColumns-1)*spacing)
//    let minHeight = CGFloat(nbRows * 100 + (nbRows-1)*spacing)

    let generator = GridDateGenerator(firstDay: 1, cType: hcal.calendarType, year: hcal.year, month: hcal.month)
    
    return VStack(alignment: .center, spacing: 1){
      
      GeometryReader { geometry in
        ForEach((0...6), id: \.self) {dayIndex in
          Text(self.weekDaysLetter[dayIndex])
            .fontWeight(.bold)
            .gridOffset(nbRows: 1, nbColumns: 7, spacing: 1, inSize: geometry.size, index: dayIndex)
        }
      }
      .padding([.top, .bottom], 2)
      .frame(width: nil, height: 20, alignment: .center)
      
      GeometryReader { geometry in
        ForEach((0..<nbColumns), id: \.self) {j in
          ForEach((0..<nbRows), id: \.self){i in
            DayView(date: generator.dateAt(i, j) ?? SimpleDate(calendarType: self.hcal.calendarType, absolute: 0))
              .gridOffset(nbRows: nbRows,
                          nbColumns: nbColumns,
                          spacing: spacing,
                          inSize: geometry.size,
                          index: i * nbColumns + j)
          }
        }
      }
    }
    .background(theme == .light ? Color(white: 0.84) : Color(white: 0.26))
    .frame(minWidth: minWidth)//,
//           idealWidth: minWidth,
//           minHeight: minHeight,
//           idealHeight: minHeight,
//           alignment: .center)
  }
}

#if DEBUG
struct MonthGrid_Previews : PreviewProvider {
  static var previews: some View {
    MonthGrid().environmentObject(HCal())
      .frame(width: 900, height: 700, alignment: .center)
  }
}
#endif

//
//  MonthGrid.swift
//  HCal
//
//  Created by Gerard Iglesias on 19/07/2019.
//

import SwiftUI

struct MonthGrid : View {
  static let calendar = Calendar(identifier: .gregorian)

  @Environment(\.colorScheme) var theme
  @EnvironmentObject var hcal: HCal
  @Binding var date : Date
  private let weekDaysLetter = calendar.weekdaySymbols.map{$0.prefix(1)}

  
  func firstDate() {
    
  }
  
  var body: some View {
  
    VStack(alignment: .center, spacing: 1){
      
      HStack(alignment: .center, spacing: 1) {
        ForEach((1...7), id: \.self) {dayIndex in
          HStack{
            Spacer()
            Text(self.weekDaysLetter[dayIndex-1])
            Spacer()
          }
        }
      }
      .background(theme == .light ? Color(white: 0.84) : Color(white: 0.26))
      .padding([.top, .bottom], 2)
      
      HStack(alignment: .center, spacing: 1){
        ForEach((1...7), id: \.self) {_ in
          VStack(alignment: .center, spacing: 1) {
            ForEach((1...6), id: \.self){_ in
              DayView(date: self.date)
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
    MonthGrid(date: .constant(Date()))
  }
}
#endif

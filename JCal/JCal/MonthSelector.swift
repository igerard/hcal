//
//  MonthSelector.swift
//  HCal
//
//  Created by Gerard Iglesias on 19/07/2019.
//

import SwiftUI

struct MonthSelector : View {
  @Environment(\.colorScheme) var theme
  @EnvironmentObject var hcal: HCal
  
  func formattedYear(year: Int) -> String {
    return String(format: "%d", year)
  }
  
  var body: some View {
    
    HStack(alignment: .bottom, spacing: 0) {
          Text("\(hcal.monthName) - \(formattedYear(year: hcal.year))")
          .font(.largeTitle)
          .baselineOffset(-5)
          .padding(.leading, 20)
          .allowsTightening(true)
      Spacer()
      Text("\(hcal.hebrewMonths) - \(formattedYear(year: hcal.hebrewYear))")
        .padding(.trailing, 40)
        .font(.headline)
        .allowsTightening(true)
      
      Button(action: {
        withAnimation(.easeOut) {
          self.hcal.decrementMonth()
        }
      }) {
        Text("⇦")
      }
      .focusable(false)
      Button(action: {
        withAnimation(.easeOut) {
          self.hcal.toThisYearAndMonth()
        }
      }) {
        Text("♢")
      }
      .focusable(false)
      Button(action: {
        withAnimation(.easeOut) {
          self.hcal.incrementMonth()
        }
      }) {
        Text("⇨")
      }
      .padding(.trailing, 10)
      .focusable(false)
    }
    .padding(.top, 10)
    .padding([.bottom], 5)
  }
}

#if DEBUG
struct MonthSelector_Previews : PreviewProvider {
  static var previews: some View {
    MonthSelector().environmentObject(HCal())
  }
}
#endif

//      DatePicker(selection: $date, displayedComponents: .date){
//        Text("Goal Date").bold()
//      }
//      .datePickerStyle(.stepperField)

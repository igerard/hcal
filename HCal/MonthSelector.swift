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
  @Binding var date: Date
  
  var body: some View {
    
    return HStack(alignment: .bottom, spacing: 0) {
      Text("\(hcal.monthName) - \(hcal.year)")
        .font(.largeTitle)
        .baselineOffset(-5)
        .padding(.leading, 20)
      Spacer()
      Text("\(hcal.hebrewMonths) - \(hcal.hebrewYear)")
        .padding(.trailing, 40)
      Button(action: {
        self.hcal.decrementMonth()
      }) {
        Text("<")
      }
      Button(action: {
        self.hcal.today()
      }) {
        Text("today")
      }
      Button(action: {
        self.hcal.incrementMonth()
      }) {
        Text(">")
      }
      .padding(.trailing, 10)
    }
      .padding(.top, 10)
      .padding([.bottom], 5)
  }
}

#if DEBUG
struct MonthSelector_Previews : PreviewProvider {
  static var previews: some View {
    MonthSelector(date: .constant(Date())).environmentObject(HCal())
  }
}
#endif

//      DatePicker(selection: $date, displayedComponents: .date){
//        Text("Goal Date").bold()
//      }
//      .datePickerStyle(.stepperField)

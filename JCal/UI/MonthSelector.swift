//
//  MonthSelector.swift
//  HCal
//
//  Created by Gerard Iglesias on 19/07/2019.
//

import SwiftUI

struct SimpleButtonStyle: ButtonStyle {
  @Environment(\.colorScheme) var theme
  func pressColor(isPressed: Bool) -> Color{
      if isPressed {
        return Color.accentColor
      }
      else {
        switch theme {
        case .dark:
          return Color.white
        case .light:
          return Color.gray
        default:
          return Color.white
        }
      }
  }
  
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .padding([.trailing, .leading], 10)
      .padding([.top, .bottom], 1)
      .background(
        RoundedRectangle(cornerRadius: 5)
          .fill(pressColor(isPressed: configuration.isPressed))
          .overlay(RoundedRectangle(cornerRadius: 5)
            .stroke(lineWidth: 1)
            .foregroundColor(Color.gray)
//            .blur(radius: 1)
        )
    )
  }
}

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
            .padding(.leading, 15.0)
            .allowsTightening(true)
      Spacer()
      Text("\(hcal.hebrewMonths) - \(formattedYear(year: hcal.hebrewYear))")
        .padding(.trailing, 40)
        .font(.title)
        .allowsTightening(true)
      
      HStack(alignment: .center, spacing: 15){
        Button(action: {
          self.hcal.decrementMonth()
        }) {
          Text("⇦")
        }

        Button(action: {
          self.hcal.toThisYearAndMonth()
        }) {
          Text("♢")
        }
        
        Button(action: {
            self.hcal.incrementMonth()
        }) {
          Text("⇨")
        }
      }
      .buttonStyle(SimpleButtonStyle())
      .font(.headline)
      .padding(.trailing, 10)
    }
    .padding(.top, 5)
    .padding(.bottom, 5)
    .fixedSize(horizontal: false, vertical: true)
  }
}

#if DEBUG
struct MonthSelector_Previews : PreviewProvider {
  static var previews: some View {
    MonthSelector().environmentObject(HCal())
      .frame(minWidth: 830)
  }
}
#endif

//      DatePicker(selection: $date, displayedComponents: .date){
//        Text("Goal Date").bold()
//      }
//      .datePickerStyle(.stepperField)

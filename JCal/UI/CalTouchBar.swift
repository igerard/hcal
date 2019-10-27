//
//  CalTouchBar.swift
//  JCal
//
//  Created by Gerard Iglesias on 12/09/2019.
//  Copyright © 2019 Gerard Iglesias. All rights reserved.
//

import SwiftUI

struct CalTouchBar: View {
  @EnvironmentObject var hcal: HCal
  
  var body: some View {
    HStack(alignment: .center, spacing: 30) {
      Spacer()
      HStack{
        Button(action: {
          self.hcal.calendarType = (self.hcal.calendarType == .gregorian ? .julian : .gregorian)
        }, label: {
          Text(self.hcal.calendarType == .gregorian ? "Julian" : "Gregorian")
        })
        Button(action: {
          self.hcal.holidayArea = (self.hcal.holidayArea == .diaspora ? .israel : .diaspora)
        }, label: {
          Text(self.hcal.holidayArea == .diaspora ? "Israel" : "Diaspora")
        })
      }
      Spacer()
      HStack{
        Button(action: {
          self.hcal.parchaActive = !self.hcal.parchaActive
        }, label: {
          Text("Parsha")
        }).foregroundColor(self.hcal.parchaActive ? Color.blue : Color.white)
        Button(action: {
          self.hcal.omerActive = !self.hcal.omerActive
        }, label: {
          Text("Omer")
        }).foregroundColor(self.hcal.omerActive ? Color.blue : Color.white)
        Button(action: {
          self.hcal.cholActive = !self.hcal.cholActive
        }, label: {
          Text("Chol")
        }).foregroundColor(self.hcal.cholActive ? Color.blue : Color.white)
      }
      Spacer()
      HStack{
        Button(action: {
          self.hcal.decrementMonth()
        }, label: {
          Text("Previous")
        })
        Button(action: {
          self.hcal.toThisYearAndMonth()
        }, label: {
          Text("Today")
        })
        Button(action: {
          self.hcal.incrementMonth()
        }, label: {
          Text("Next")
        })
      }
    }
  }
}

struct CalTouchBar_Previews: PreviewProvider {
  static var previews: some View {
    CalTouchBar().environmentObject(HCal())
  }
}

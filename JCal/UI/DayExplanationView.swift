//
//  DayExplanationView.swift
//  JCal
//
//  Popover shown when tapping a day: secular + Hebrew date and a color-coded
//  list of the day's holidays / events with localized explanations.
//

import SwiftUI

struct DayExplanationView: View {
  @Environment(HebrewCalendar.self) private var hcal
  let date: SimpleDate

  var body: some View {
    let hdate = SecularToHebrewConversion(date.year,
                                          date.month,
                                          date.day,
                                          hcal.calendarType == .julian)
    let names = HolidayInfo.names(for: date, in: hcal)

    VStack(alignment: .leading, spacing: 12) {
      VStack(alignment: .leading, spacing: 2) {
        Text(secularDateString)
          .font(.headline)
        Text("\(hdate.day) \(String(cString: hdate.hebrew_month_name)) \(String(hdate.year))")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }

      if names.isEmpty {
        Text("No holiday or event on this day.")
          .font(.callout)
          .foregroundStyle(.secondary)
      } else {
        Divider()
        VStack(alignment: .leading, spacing: 10) {
          ForEach(names, id: \.self) { name in
            HolidayExplanationRow(name: name)
          }
        }
      }
    }
    .padding(16)
    .frame(width: 320, alignment: .leading)
  }

  private var secularDateString: String {
    let weekdays = HebrewCalendar.calendar.weekdaySymbols
    let months = HebrewCalendar.calendar.monthSymbols
    let weekday = weekdays[(date.weekday - 1) % 7]
    let month = months[(date.month - 1) % 12]
    return "\(weekday) \(date.day) \(month) \(date.year)"
  }
}

/// A single holiday row: a colored category bar, the holiday title in the
/// category color, and its localized explanation.
private struct HolidayExplanationRow: View {
  let name: String

  var body: some View {
    let category = HolidayInfo.category(for: name)
    let color = Theming.holidayCategoryColor(category)

    HStack(alignment: .top, spacing: 8) {
      RoundedRectangle(cornerRadius: 2)
        .fill(color)
        .frame(width: 4)

      VStack(alignment: .leading, spacing: 2) {
        Text(name)
          .font(.subheadline.bold())
          .foregroundStyle(color)
        Text(category.localizedName)
          .font(.caption2)
          .foregroundStyle(color.opacity(0.8))
        Text(HolidayInfo.explanation(for: name))
          .font(.caption)
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)
        if let url = HolidayInfo.learnMoreURL(for: name) {
          Link("Learn more", destination: url)
            .font(.caption2)
            .padding(.top, 1)
            .focusable(false)
            .focusEffectDisabled()
        }
      }
    }
  }
}

#Preview {
  let hcal: HebrewCalendar = {
    let h = HebrewCalendar()
    h.year = 2026
    h.month = 9
    return h
  }()

  DayExplanationView(date: SimpleDate(calendarType: .gregorian,
                                      year: 2026, month: 7, day: 4))
  .environment(hcal)
  
}

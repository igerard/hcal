import Foundation
import Cocoa

let date = Date()

print(date.description)

var calendar = Calendar(identifier: .gregorian)
calendar.locale = Locale.current

let components = calendar.dateComponents([.era, .year, .day, .month], from: date)

print(components.era!)
print(components.day!)
print(components.month!)
print(components.year!)

print(calendar.monthSymbols)

calendar.range(of: .day, in: .month,
               for: calendar.date(from: DateComponents(calendar: calendar,
                                                       timeZone: nil,
                                                       era: nil,
                                                       year: 2020,
                                                       month: 2,
                                                       day: 1,
                                                       hour: nil,
                                                       minute: nil,
                                                       second: nil,
                                                       nanosecond: nil,
                                                       weekday: nil,
                                                       weekdayOrdinal: nil,
                                                       quarter: nil,
                                                       weekOfMonth: nil,
                                                       weekOfYear: nil,
                                                       yearForWeekOfYear: nil))!)

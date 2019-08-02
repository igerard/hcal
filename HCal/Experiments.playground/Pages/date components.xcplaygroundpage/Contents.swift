import Foundation
import Cocoa

var calendar = Calendar(identifier: .gregorian)
calendar.locale = Locale.current

let components = DateComponents(calendar: calendar,
                                timeZone: nil,
                                era: nil,
                                year: 2019,
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
                                yearForWeekOfYear: nil)

calendar.range(of: .day, in: .month,
               for: calendar.date(from: components)!)


let date = calendar.date(from: DateComponents(calendar: calendar,
                                                       timeZone: nil,
                                                       era: nil,
                                                       year: 2019,
                                                       month: 7,
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
                                                       yearForWeekOfYear: nil))

let weekday = calendar.dateComponents([.weekday], from: date!).weekday!

calendar.weekdaySymbols[weekday - 1]

calendar.firstWeekday

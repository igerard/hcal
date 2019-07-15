import Foundation
import Cocoa

let date = Date()

print(date.description)

let components = Calendar(identifier: .gregorian).dateComponents([.era, .year, .day, .month], from: date)

print(components.era)
print(components.day)
print(components.month)
print(components.year)

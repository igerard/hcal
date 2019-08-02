//: [Previous](@previous)

import Foundation

var calendar = Calendar(identifier: .gregorian)
calendar.locale = Locale.current

let t = calendar.weekdaySymbols.map{$0.prefix(1)}

print(t)

let year = 2022
let month = 6
let day = 1

//: [Next](@next)

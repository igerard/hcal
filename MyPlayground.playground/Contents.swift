import Foundation
import Cocoa

var str = "Hello, playground"

enum CalendarType: String, CaseIterable, Encodable, Decodable {
  case gregorian = "Gregorian"
  case julian = "Julian"
}

struct Wrapper<T: Encodable & Decodable> : Codable{
  let value : T
}

do {
  let encoder = JSONEncoder()
  let data = try encoder.encode(Wrapper<CalendarType>(value: CalendarType.gregorian))
  print(data.debugDescription)
  let wrapper = try JSONDecoder().decode(Wrapper<CalendarType>.self, from: data)
  print("\(wrapper.value)")
}
catch {
  print(error.localizedDescription)
}

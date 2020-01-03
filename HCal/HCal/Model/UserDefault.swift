//
//  UserDefault.swift
//  HCal
//
//  Created by Gerard Iglesias on 08/08/2019.
//

import Foundation

infix operator <- : AssignmentPrecedence
infix operator == : ComparisonPrecedence
infix operator != : ComparisonPrecedence
//infix operator < : ComparisonPrecedence
//infix operator > : ComparisonPrecedence

//@propertyWrapper
struct UserDefault<T> where T : Codable, T : Equatable {
  let key: String
  let defaultValue: T
  
  init(_ key: String, defaultValue: T) {
    self.key = key
    self.defaultValue = defaultValue
  }
  
  var wrappedValue: T {
    get {
      let data = UserDefaults.standard.data(forKey: key)
      let value = data.flatMap { try? JSONDecoder().decode(T.self, from: $0) }
      return value ?? defaultValue
    }
    set {
      let data = try? JSONEncoder().encode(newValue)
      UserDefaults.standard.set(data, forKey: key)
    }
  }

  static func <- (left: inout UserDefault, right: T) {
    left.wrappedValue = right
  }

  static func == (left: UserDefault, right: T) -> Bool {
    return left.wrappedValue == right
  }

  static func == (left: UserDefault, right: UserDefault) -> Bool {
    return left.wrappedValue == right.wrappedValue
  }

  static func == (left: T, right: UserDefault) -> Bool {
    return right.wrappedValue == left
  }

  static func != (left: UserDefault, right: T) -> Bool {
    return left.wrappedValue != right
  }

  static func != (left: UserDefault, right: UserDefault) -> Bool {
    return left.wrappedValue != right.wrappedValue
  }

//  static func < (left: UserDefault, right: UserDefault) -> Bool {
//    return left.wrappedValue < right.wrappedValue
//  }
//
//  static func < (left: UserDefault, right: T) -> Bool {
//    return left.wrappedValue < right
//  }
//
//  static func < (left: UserDefault, right: UserDefault) -> Bool {
//    return left.wrappedValue < right.wrappedValue
//  }
//
//  static func > (left: UserDefault, right: UserDefault) -> Bool {
//    return left.wrappedValue > right.wrappedValue
//  }
//
//  static func > (left: UserDefault, right: T) -> Bool {
//    return left.wrappedValue > right
//  }
//
//  static func > (left: UserDefault, right: UserDefault) -> Bool {
//    return left.wrappedValue > right.wrappedValue
//  }
}

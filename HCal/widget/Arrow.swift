//
//  toLeft.swift
//  HCal
//
//  Created by Gerard Iglesias on 07/08/2019.
//

import SwiftUI

enum Direction {
  case left
  case right
}

struct Arrow: View {
  let direction : Direction
  let command : () -> Void
  
  func text() -> String {
    switch direction {
    case .left :
      return "⇦"
      case .right :
        return "⇨"
    }
  }
  
  var body: some View {
    Button(action: command) {
      Text(text())
      
//      LEFTWARDS WHITE ARROW
//      Unicode: U+21E6, UTF-8: E2 87 A6
      
//      Image("LeftArrow").resizable()
//        .frame(width: 12, height: 12, alignment: .center)

//      GeometryReader { geometry in
//        Path { path in
//          let width = geometry.size.width
//          let height = geometry.size.height
//          let spacing = width * 0.030
//          let middle = width / 2
//          let dirX : CGFloat = spacing
//
//          path.addLines([
//            CGPoint(x: middle, y: spacing),
//            CGPoint(x: dirX, y: middle),
//            CGPoint(x: middle, y: height - spacing),
//          ])
//        }
//        .stroke(Color.black, lineWidth: 2)
//      }
    }
  }
}

#if DEBUG
struct toLeft_Previews: PreviewProvider {
  static var previews: some View {
    Arrow(direction: .left) {
      print("Ho My God")
    }
    .frame(width: 16, height: 16, alignment: .center)
  }
}
#endif

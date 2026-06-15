//
//  CellInGrid.swift
//  JCal
//
//  Created by Gerard Iglesias on 25/03/2020.
//  Copyright © 2020 Gerard Iglesias. All rights reserved.
//

import SwiftUI

extension Bool {
  func trueOrElse<T>(_ ifTrue: T, _ ifFalse: T) -> T {
    if self {
      return ifTrue
    }else {
      return ifFalse
    }
  }
}

struct CellInGrid<Content>: View where Content: View{
  let view : Content
  let nbRows: Int
  let nbColumns: Int
  let spacing: Int
  let inSize: CGSize
  let index : Int
  
  var body: some View {
    let width = inSize.width / CGFloat(nbColumns)
    let height = inSize.height / CGFloat(nbRows)
    let row = index / nbColumns
    let column = index - (row*nbColumns)
    let x1 = (column == 0)
      .trueOrElse(0, Int(CGFloat(column) * width - CGFloat(spacing)/2.0) + spacing)
    let y1 = (row == 0)
      .trueOrElse(0, max(0, Int(CGFloat(row) * height - CGFloat(spacing)/2) + spacing))
    let x2 = (column == nbColumns - 1)
      .trueOrElse(Int(inSize.width), Int(CGFloat(column+1) * width - CGFloat(spacing)/2.0))
    let y2 = (row == nbRows - 1)
      .trueOrElse(Int(inSize.height), Int(CGFloat(row+1) * height - CGFloat(spacing)/2.0))
    
    return view
      .frame(width: CGFloat(x2-x1), height: CGFloat(y2-y1), alignment: .center)
      .clipped()
      .offset(x: CGFloat(x1), y: CGFloat(y1))
  }
}

extension View {
  func gridOffset(nbRows: Int, nbColumns: Int, spacing: Int, inSize: CGSize, index : Int) -> some View {
    return CellInGrid(view: self, nbRows: nbRows, nbColumns: nbColumns, spacing: spacing, inSize: inSize, index: index)
  }
}

#if DEBUG
struct CellInGrid_Previews: PreviewProvider {
  
  static var previews: some View {
    let nbRows = 6
    let nbColumns = 7
    let spacing = 1

    return ZStack{
      Rectangle()
        .foregroundColor(Color.gray)
      
      GeometryReader { geo in
        ForEach(0..<nbRows*nbColumns, id: \.self) { index in
          Text("\(index)").frame(maxWidth: 1000, maxHeight: 1000).background(Color.white)
            .gridOffset(nbRows: nbRows,
                        nbColumns: nbColumns,
                        spacing: spacing,
                        inSize: geo.size,
                        index: index)
        }
      }
    }
    .frame(width: 800, height: 600, alignment: .center)
  }
}
#endif

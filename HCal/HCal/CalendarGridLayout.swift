//
//  CalendarGeridLayout.swift
//  HCal
//
//  Created by Gerard Iglesias on 24/10/2019.
//  Copyright © 2019 Gerard Iglesias. All rights reserved.
//

import AppKit

class CalendarGridLayout: NSCollectionViewLayout {
  
  var nbRows = 6
  var nbColums = 7
  var gap = (width: 2, height: 2)
  var discreteX: [[CGFloat]] = []
  var discreteY: [[CGFloat]] = []
  
  func generateIntervals(length: CGFloat, nb: Int, space: Int) -> [[CGFloat]] {
    return (0..<nb).map{ i -> [CGFloat] in
      let x = CGFloat(i) * length / CGFloat(nb)
      let xw = CGFloat(i+1) * length / CGFloat(nb)
      return [round(x) + (x==0.0 ? 0.0 : 1.0), round(xw)-(xw == length ? 0.0 : 1.0)]
    }
  }

  override func prepare() {
    //print(collectionView?.bounds.debugDescription ?? "No collection view ?")
    if let bsize = collectionView?.bounds.size {
      discreteX = generateIntervals(length: bsize.width, nb: nbColums, space: gap.width)
      discreteY = generateIntervals(length: bsize.height, nb: nbRows, space: gap.height)
    }
  }
  
  override var collectionViewContentSize: NSSize {
    get {
      return collectionView!.bounds.size
    }
  }
  
  override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
    //print("attributes for  \(rect.debugDescription)")
    return (0..<nbRows*nbColums).compactMap{layoutAttributesForItem(at: IndexPath(item: $0, section: 0))}
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
    let row = indexPath[1] / nbColums
    let col = indexPath[1] % nbColums
    //print("\(indexPath.debugDescription) : \(row) - \(col)")
    let attribute = NSCollectionViewLayoutAttributes(forItemWith: indexPath)
    attribute.frame = NSRect(x: discreteX[col][0], y: discreteY[row][0], width: discreteX[col][1] - discreteX[col][0], height: discreteY[row][1] - discreteY[row][0])
    return attribute
  }
  
  override func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
    true
  }
}

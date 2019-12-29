//
//  DiskView.swift
//  HCal
//
//  Created by Gerard Iglesias on 28/10/2019.
//  Copyright © 2019 Gerard Iglesias. All rights reserved.
//

import AppKit

class DiskView: NSView {
  
  override func draw(_ dirtyRect: NSRect) {
    NSColor(named: NSColor.Name("dayDisk"))!.set()
    NSBezierPath(ovalIn: bounds).fill()
  }
}

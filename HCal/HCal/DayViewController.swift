//
//  DayViewController.swift
//  HCal
//
//  Created by Gerard Iglesias on 24/10/2019.
//  Copyright © 2019 Gerard Iglesias. All rights reserved.
//

import AppKit

class DayViewController: NSCollectionViewItem {
  
  let date : SimpleDate? = nil

  @objc dynamic var day: Int = 0
  
  @IBOutlet var dayNumber:   NSTextField? = nil
  @IBOutlet var dayName:     NSTextField? = nil
  @IBOutlet var specialDay2: NSTextField? = nil
  @IBOutlet var specialDay1: NSTextField? = nil
}

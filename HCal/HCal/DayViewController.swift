//
//  DayViewController.swift
//  HCal
//
//  Created by Gerard Iglesias on 24/10/2019.
//  Copyright © 2019 Gerard Iglesias. All rights reserved.
//

import AppKit

class DayViewController: NSCollectionViewItem {
  @IBOutlet var dayNumber:   NSTextField!
  @IBOutlet var dayName:     NSTextField!
  @IBOutlet var specialDay2: NSTextField!
  @IBOutlet var specialDay1: NSTextField!
  @IBOutlet weak var diskView: DiskView!
}

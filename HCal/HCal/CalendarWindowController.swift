//
//  CalendarWindowController.swift
//  HCal
//
//  Created by Gerard Iglesias on 29/10/2019.
//  Copyright © 2019 Gerard Iglesias. All rights reserved.
//

import AppKit
import Combine

class CalendarWindowController: NSWindowController {

  var hcal: HCal!
  
  @IBOutlet var menuItem : NSMenuItem?
  @IBOutlet var gregorianMenuItem : NSMenuItem?
  @IBOutlet var julianMenuItem : NSMenuItem?
  @IBOutlet var israelMenuItem : NSMenuItem?
  @IBOutlet var diasporaMenuItem : NSMenuItem?
  @IBOutlet var parshaMenuItem : NSMenuItem?
  @IBOutlet var omerMenuItem : NSMenuItem?
  @IBOutlet var cholMenuItem : NSMenuItem?
  
  @IBOutlet var calendarToolBarItem : NSSegmentedControl?
  @IBOutlet var holidayAreaToolBarItem : NSSegmentedControl?
  @IBOutlet var parshaToolBarItem : NSButton?
  @IBOutlet var omerToolBarItem : NSButton?
  @IBOutlet var cholToolBarItem : NSButton?
  
  override func windowDidLoad() {
    guard let calendarController = contentViewController as? CalendarController else {
      return
    }
    hcal = calendarController.hcal
    
    if let menu = NSApp.mainMenu,
      let item = menuItem {
      menu.insertItem(item, at: menu.numberOfItems-2)
    }
    
    // Menu item
    NotificationCenter.default.addObserver(forName: HCal.hcalModifiedName, object: hcal, queue: .main) { _ in
      self.syncMenuItems()
    }
    syncMenuItems()
  }
  
  
  fileprivate func syncMenuItems() {
    gregorianMenuItem?.state = (hcal.calendarType == .gregorian ? .on : .off)
    julianMenuItem?.state = (hcal.calendarType == .julian ? .on : .off)
    israelMenuItem?.state = (hcal.holidayArea == .israel ? .on : .off)
    diasporaMenuItem?.state = (hcal.holidayArea == .diaspora ? .on : .off)
    parshaMenuItem?.state = hcal.parchaActive ? .on : .off
    omerMenuItem?.state = hcal.omerActive ? .on : .off
    cholMenuItem?.state = hcal.cholActive ? .on : .off
    
    calendarToolBarItem?.setSelected(hcal.calendarType == .gregorian, forSegment: 0)
    calendarToolBarItem?.setSelected(hcal.calendarType == .julian, forSegment: 1)
    holidayAreaToolBarItem?.setSelected(hcal.holidayArea == .diaspora, forSegment: 0)
    holidayAreaToolBarItem?.setSelected(hcal.holidayArea == .israel, forSegment: 1)
    parshaToolBarItem?.state = hcal.parchaActive ? .on : .off
    omerToolBarItem?.state = hcal.omerActive ? .on : .off
    cholToolBarItem?.state = hcal.cholActive ? .on : .off
  }
  
  // Menu actions
  @IBAction func gregorianToggle(_ sender: NSMenuItem) {
    sender.state = (sender.state == .on ? .off : .on)
    julianMenuItem?.state = (sender.state == .on ? .off : .on)
    hcal.calendarType = (sender.state == .on ? .gregorian : .julian)
  }
  
  @IBAction func resetOptions(_ sender: NSMenuItem) {
    hcal.holidayArea = .diaspora
    hcal.calendarType = .gregorian
    hcal.parchaActive = false
    hcal.omerActive = false
    hcal.cholActive = false
  }
  
  @IBAction func julianToggle(_ sender: NSMenuItem) {
    sender.state = (sender.state == .on ? .off : .on)
    gregorianMenuItem?.state = (sender.state == .on ? .off : .on)
    hcal.calendarType = (sender.state == .on ? .julian : .gregorian)
  }
  
  @IBAction func israelToggle(_ sender: NSMenuItem) {
    sender.state = (sender.state == .on ? .off : .on)
    diasporaMenuItem?.state = (sender.state == .on ? .off : .on)
    hcal.holidayArea = (sender.state == .on ? .israel : .diaspora)
  }
  
  @IBAction func diasporaToggle(_ sender: NSMenuItem) {
    sender.state = (sender.state == .on ? .off : .on)
    israelMenuItem?.state = (sender.state == .on ? .off : .on)
    hcal.holidayArea = (sender.state == .on ? .diaspora : .israel)
  }
  
  @IBAction func parshaToggle(_ sender: NSMenuItem) {
    sender.state = (sender.state == .on ? .off : .on)
    hcal.parchaActive = sender.state == .on
  }
  
  @IBAction func omerToggle(_ sender: NSMenuItem) {
    sender.state = (sender.state == .on ? .off : .on)
    hcal.omerActive = sender.state == .on
  }
  
  @IBAction func cholToggle(_ sender: NSMenuItem) {
    sender.state = (sender.state == .on ? .off : .on)
    hcal.cholActive = sender.state == .on
  }
  
}

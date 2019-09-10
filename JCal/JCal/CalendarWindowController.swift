//
//  CalendarWindowController.swift
//  HCal
//
//  Created by Gerard Iglesias on 10/08/2019.
//

import Foundation
import AppKit
import SwiftUI
import Combine

class CalendarWindowController : NSWindowController {
  var subscription : AnyCancellable!
  
  var hcal = HCal()
  
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
    window?.contentView = NSHostingView(rootView:MainCalendarView().environmentObject(hcal))
    
    if let menu = NSApp.mainMenu,
      let item = menuItem {
      menu.insertItem(item, at: menu.numberOfItems-2)
    }
    
    // Menu item
    subscription = hcal.objectWillChange.sink {
      self.syncMenuItems()
    }
    syncMenuItems()
    
    // set the toolbar at the top without title
    window?.titleVisibility = .hidden
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

  // Toolbar actions
  @IBAction func calendarChosen(_ sender: NSSegmentedControl) {
    hcal.calendarType = (sender.selectedSegment == 0 ? .gregorian : .julian)
  }

  @IBAction func holidayAreaChosen(_ sender: NSSegmentedControl) {
    hcal.holidayArea = (sender.selectedSegment == 0 ? .diaspora : .israel)
  }

  @IBAction func parshaChosen(_ sender: NSButton) {
    hcal.parchaActive = sender.state == .on
  }

  @IBAction func omerChosen(_ sender: NSButton) {
    hcal.omerActive = sender.state == .on
  }

  @IBAction func cholChosen(_ sender: NSButton) {
    hcal.cholActive = sender.state == .on
  }

  override func keyDown(with event: NSEvent) {
    switch event.keyCode {
    case 121:
      withAnimation{
        hcal.toThisYearAndMonth()
      }
    case 123:
      withAnimation{
        hcal.decrementMonth()
      }
    case 124:
      withAnimation{
        hcal.incrementMonth()
      }
    case 125:
      withAnimation{
        hcal.year -= 1
      }
    case 126:
      withAnimation{
        hcal.year += 1
      }
    default:
      print("\(event)")
      break;
    }
  }
}

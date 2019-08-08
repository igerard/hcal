//
//  AppDelegate.swift
//  HCal
//
//  Created by Gerard Iglesias on 08/07/2019.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  var window: NSWindow!
  
  var hcal = HCal()

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
    window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
        styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
        backing: .buffered, defer: false)
    window.center()

    window.contentView = NSHostingView(rootView:
      MainCalendarView().environmentObject(hcal))

    window.makeKeyAndOrderFront(nil)
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }


}


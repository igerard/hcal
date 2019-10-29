//
//  ViewController.swift
//  HCal
//
//  Created by Gerard Iglesias on 16/09/2019.
//  Copyright © 2019 Gerard Iglesias. All rights reserved.
//

import Cocoa
import Combine

class CalendarController: NSViewController {
  var subscription : AnyCancellable!

  var hcal = HCal()
  var dateGenerator : GridDateGenerator

  let ids = [NSUserInterfaceItemIdentifier("DayItem")]
  let nbItems = [42]

  @IBOutlet var monthGridView: NSCollectionView!
  @IBOutlet weak var hebrewMonthsField: NSTextField!
  @IBOutlet weak var monthField: NSTextField!
  
  override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
    dateGenerator = GridDateGenerator(firstDay: 1, cType: hcal.calendarType, year: hcal.year, month: hcal.month)
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    representedObject = hcal
    
    subscription = hcal.objectWillChange.sink {
      self.updateUI()
    }
  }
  
  required init?(coder: NSCoder) {
    dateGenerator = GridDateGenerator(firstDay: 1, cType: hcal.calendarType, year: hcal.year, month: hcal.month)
    super.init(coder: coder)
    representedObject = hcal

    subscription = hcal.objectWillChange.sink {
      self.updateUI()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    ids.forEach{monthGridView?.register(NSNib(nibNamed: NSNib.Name($0.rawValue), bundle: Bundle.main), forItemWithIdentifier: $0)}
    updateUI()
  }

  func formattedYear(year: Int) -> String {
    return String(format: "%d", year)
  }

  func updateUI() {
    monthField.stringValue =  "\(hcal.monthName) - \(formattedYear(year: hcal.year))"
    hebrewMonthsField.stringValue = "\(hcal.hebrewMonths) - \(formattedYear(year: hcal.hebrewYear))"
    self.dateGenerator = GridDateGenerator(firstDay: 1, cType: self.hcal.calendarType, year: self.hcal.year, month: self.hcal.month)
    self.monthGridView?.reloadData()
  }
  override var representedObject: Any? {
    didSet {
    }
  }

  @IBAction func previousMonth(_ sender: Any) {
    hcal.decrementMonth()
  }
  
  @IBAction func todayMonth(_ sender: Any) {
    hcal.toThisYearAndMonth()
  }
  
  @IBAction func nextMonth(_ sender: Any) {
    hcal.incrementMonth()
  }
  
}

extension CalendarController: NSCollectionViewDelegate, NSCollectionViewDataSource {
  
  func numberOfSections(in collectionView: NSCollectionView) -> Int{
    return nbItems.count
  }

  func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    return nbItems[section]
  }
  
  func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    let item  =  collectionView.makeItem(withIdentifier: ids[indexPath[0]], for: indexPath)
    
    let row = indexPath[1] / 7
    let col = indexPath[1] % 7
    
    if let ditem = item as? DayViewController,
      let date  = dateGenerator.dateAt(row, col) {
      
      let inMonth = date.month == hcal.month
      let isToday = hcal.isToday(date: date)
      let isShabbat = date.weekday == 7
      ParshaP = hcal.parchaActive
      OmerP = hcal.omerActive
      CholP = hcal.cholActive
      let hdate = SecularToHebrewConversion(Int32(date.year),
                                            Int32(date.month),
                                            Int32(date.day),
                                            hcal.calendarType == .julian)
      let holiday = FindHoliday(hdate.month,
                                hdate.day,
                                hdate.day_of_week,
                                hdate.kvia,
                                hdate.hebrew_leap_year_p,
                                hcal.holidayArea == .israel,
                                hdate.hebrew_day_number,
                                hdate.year)

      if let box = ditem.view as? NSBox {
        box.fillColor = { () -> NSColor in
          switch (inMonth, isShabbat) {
          case (true, true):
            return NSColor.textBackgroundColor.shadow(withLevel: 0.05) ?? NSColor.textBackgroundColor
          case (true, false):
            return NSColor.textBackgroundColor
          case (false, true):
            return NSColor.textBackgroundColor.shadow(withLevel: 0.07) ?? NSColor.textBackgroundColor
          case (false, false):
            return NSColor.textBackgroundColor.shadow(withLevel: 0.1) ?? NSColor.textBackgroundColor
          }
        }()
      }
      ditem.dayNumber?.stringValue = "\(date.day)"
      ditem.dayName?.stringValue = "\(hdate.day) \(String(cString: hdate.hebrew_month_name))"
      ditem.diskView.isHidden = !isToday
      
      if let p1 = holiday?.advanced(by: 1).pointee, let p2 = holiday?.pointee {
        ditem.specialDay2?.stringValue = String(cString: p2)
        ditem.specialDay1?.stringValue = String(cString: p1)
      }
      else if let p = holiday?.advanced(by: 1).pointee {
        ditem.specialDay1?.stringValue = String(cString: p)
      }
      else if let p = holiday?.pointee {
        ditem.specialDay1?.stringValue = String(cString: p)
      }
      else {
          ditem.specialDay2?.stringValue = ""
          ditem.specialDay1?.stringValue = ""
      }

    }
    return item
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
      hcal.toThisYearAndMonth()
    case 123:
      hcal.decrementMonth()
    case 124:
      hcal.incrementMonth()
    case 125:
      hcal.year -= 1
    case 126:
      hcal.year += 1
    default:
      print("\(event)")
      break;
    }
  }

}

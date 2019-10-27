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

  let ids = [NSUserInterfaceItemIdentifier("DayViewItem"), NSUserInterfaceItemIdentifier("WeekDayItem")]
  let nbItems = [7,42]

  @IBOutlet var monthGridView: NSCollectionView? = nil

  override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
    dateGenerator = GridDateGenerator(firstDay: 1, cType: hcal.calendarType, year: hcal.year, month: hcal.month)
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    representedObject = hcal
    
    subscription = hcal.objectWillChange.sink {
      self.dateGenerator = GridDateGenerator(firstDay: 1, cType: self.hcal.calendarType, year: self.hcal.year, month: self.hcal.month)
      self.monthGridView?.reloadData()
    }
  }
  
  required init?(coder: NSCoder) {
    dateGenerator = GridDateGenerator(firstDay: 1, cType: hcal.calendarType, year: hcal.year, month: hcal.month)
    super.init(coder: coder)
    representedObject = hcal
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    ids.forEach{monthGridView?.register(NSNib(nibNamed: NSNib.Name($0.rawValue), bundle: Bundle.main), forItemWithIdentifier: $0)}
  }

  override var representedObject: Any? {
    didSet {
    }
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
    let item = collectionView.makeItem(withIdentifier: ids[indexPath[0]], for: indexPath)
    item.syncDataWith(calendar: hcal, gridGenerator: dateGenerator, forPosition: indexPath)
    return item
  }
}

protocol CalendarFillingProtocol {
  func syncDataWith(calendar: HCal, gridGenerator: GridDateGenerator, forPosition: IndexPath)
}

extension NSCollectionViewItem: CalendarFillingProtocol {
  func syncDataWith(calendar: HCal, gridGenerator: GridDateGenerator, forPosition: IndexPath){
    // do nothing here
  }
}

extension DayViewController {
  override func syncDataWith(calendar: HCal, gridGenerator: GridDateGenerator, forPosition: IndexPath){
    
  }
}

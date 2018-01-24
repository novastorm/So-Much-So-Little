//
//  TimeboxControlRow.swift
//  So Much So Little
//
//  Created by Adland Lee on 7/10/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import Eureka
import UIKit

private var TimeboxControlCellContext = 0

open class TimeboxControlCell: Cell<Int>, CellType {
    
//    let estimatedTimeboxesKeyPath = "estimatedTimeboxes"
    
    @IBOutlet weak var timeboxControl: TimeboxControl!
    
    open override func setup() {
//        print ("\(type(of: self).typeName) setup")
        
        super.setup()
        #if swift(>=3.0)
        timeboxControl.addObserver(self, forKeyPath: #keyPath(TimeboxControl.estimatedTimeboxes), options: .new, context: &TimeboxControlCellContext)
        #elseif swift(>=2.2)
        timeboxControl.addObserver(self, forKeyPath: "estimatedTimeboxes", options: .new, context: &TimeboxControlCellContext)
        #endif
        row.value = 0
    }
    
    open override func update() {
//        print ("\(type(of: self).typeName) update")
        super.update()
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        #if swift(>=3.0)
        if keyPath == #keyPath(TimeboxControl.estimatedTimeboxes) {
            print("timeboxControl.estimatedTimeboxes changed: \(timeboxControl.estimatedTimeboxes)")
            }
        #elseif swift(>=2.2)
        if keyPath == "estimatedTimeboxes" {
            print("timeboxControl.estimatedTimeboxes changed: \(timeboxControl.estimatedTimeboxes)")
            }
        #endif
        row.value = timeboxControl.estimatedTimeboxes
    }
    
    deinit {
        #if swift(>=3.0)
        timeboxControl.removeObserver(self, forKeyPath: #keyPath(TimeboxControl.estimatedTimeboxes), context: &TimeboxControlCellContext)
        #elseif swift(>=2.2)
        timeboxControl.removeObserver(self, forKeyPath: "estimatedTimeboxes", context: &TimeboxControlCellContext)
        #endif
    }
}

public final class TimeboxControlRow: Row<TimeboxControlCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<TimeboxControlCell>(nibName: "TimeboxControlCell")
    }
}

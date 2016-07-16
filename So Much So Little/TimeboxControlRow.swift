//
//  TimeboxControlRow.swift
//  So Much So Little
//
//  Created by Adland Lee on 7/10/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import Eureka
import Foundation
import UIKit

private var TimeboxControlCellContext = 0

public class TimeboxControlCell: Cell<Int>, CellType {
    
//    let estimatedTimeboxesKeyPath = "estimatedTimeboxes"
    
    @IBOutlet weak var timeboxControl: TimeboxControl!
    
    public override func setup() {
        print ("\(self.dynamicType.className) setup")
        
        super.setup()
        #if swift(>=3.0)
        timeboxControl.addObserver(self, forKeyPath: #keyPath(TimeboxControl.estimatedTimeboxes), options: .New, context: &TimeboxControlCellContext)
        #elseif swift(>=2.2)
        timeboxControl.addObserver(self, forKeyPath: "estimatedTimeboxes", options: .New, context: &TimeboxControlCellContext)
        #endif
        row.value = 0
    }
    
    public override func update() {
        print ("\(self.dynamicType.className) update")
        super.update()
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
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

public final class TimeboxControlRow: Row<Int, TimeboxControlCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<TimeboxControlCell>(nibName: "TimeboxControlCell")
    }
}
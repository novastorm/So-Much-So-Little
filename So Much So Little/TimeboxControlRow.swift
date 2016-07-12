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
    
//    let PendingTimeboxesKeyPath = "pendingTimeboxes"
    
    @IBOutlet weak var timeboxControl: TimeboxControl!
    
    public override func setup() {
        print ("\(self.dynamicType.className) setup")
        
        super.setup()
        #if swift(>=3.0)
        timeboxControl.addObserver(self, forKeyPath: #keyPath(TimeboxControl.pendingTimeboxes), options: .New, context: &TimeboxControlCellContext)
        #elseif swift(>=2.2)
        timeboxControl.addObserver(self, forKeyPath: "pendingTimeboxes", options: .New, context: &TimeboxControlCellContext)
        #endif
    }
    
    public override func update() {
        print ("\(self.dynamicType.className) update")
        super.update()
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        #if swift(>=3.0)
        if keyPath == #keyPath(TimeboxControl.pendingTimeboxes) {
            print("timeboxControl.pendingTimeboxes changed: \(timeboxControl.pendingTimeboxes)")
            }
        #elseif swift(>=2.2)
        if keyPath == "pendingTimeboxes" {
            print("timeboxControl.pendingTimeboxes changed: \(timeboxControl.pendingTimeboxes)")
            }
        #endif
    }
    
    deinit {
        #if swift(>=3.0)
        timeboxControl.removeObserver(timeboxControl, forKeyPath: #keyPath(TimeboxControl.pendingTimeboxes), context: &TimeboxControlCellContext)
        #elseif swift(>=2.2)
        timeboxControl.removeObserver(timeboxControl, forKeyPath: "pendingTimeboxes", context: &TimeboxControlCellContext)
        #endif
    }
}

public final class TimeboxControlRow: Row<Int, TimeboxControlCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<TimeboxControlCell>(nibName: "TimeboxControlCell")
    }
}
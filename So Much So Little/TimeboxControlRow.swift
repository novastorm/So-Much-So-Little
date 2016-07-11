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

public class TimeboxControlCell: Cell<Int>, CellType {
    @IBOutlet weak var timeboxControl: TimeboxControl!
    
    public override func setup() {
        print ("\(self.dynamicType.className) setup")
        
        super.setup()
        timeboxControl.addObserver(self, forKeyPath: "pendingTimeboxes", options: .New, context: nil)
    }
    
    public override func update() {
        print ("\(self.dynamicType.className) update")
        super.update()
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        print("timeboxControl.pendingTimeboxes changed: \(timeboxControl.pendingTimeboxes)")
    }
}

public final class TimeboxControlRow: Row<Int, TimeboxControlCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<TimeboxControlCell>(nibName: "TimeboxControlCell")
    }
}
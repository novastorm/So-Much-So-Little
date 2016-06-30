//
//  ActivityDetailViewController.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/20/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import UIKit

class ActivityDetailViewController: UIViewController {
    
    var activity: Activity?
    
    
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var timeboxControl: TimeboxControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let activity = activity {
            taskTextField.text = activity.task
            
            let actualTimeboxes = activity.actual_timeboxes!
            let estimatedTimeboxes = activity.estimated_timeboxes!
            
            timeboxControl.pendingTimeboxes = estimatedTimeboxes as Int
            timeboxControl.completedTimeboxes = actualTimeboxes as Int
        }
    }
}
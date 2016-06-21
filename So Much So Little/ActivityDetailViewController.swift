//
//  ActivityDetailViewController.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/20/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import UIKit

class ActivityDetailViewController: UIViewController {
    
//    var activity: Activity?
    var activity: [String: AnyObject]?
    
    
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var timeboxesTextField: UITextField!
    
    override func viewDidLoad() {
        guard let activity = activity else {
            return
        }
        
        taskTextField.text = activity[Activity.Keys.Task] as? String
        
        let actualTimeboxes = activity[Activity.Keys.ActualTimeboxes] as? Int ?? 0
        let estimatedTimeboxes = activity[Activity.Keys.EstimatedTimeboxes] as? Int ?? 0
        timeboxesTextField.text = "\(actualTimeboxes)/\(estimatedTimeboxes)"

    }
}
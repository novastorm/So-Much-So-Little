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
    @IBOutlet weak var taskInfoTextView: UITextView!
    @IBOutlet weak var timeboxControl: TimeboxControl!
    @IBOutlet weak var projectTextField: UITextField!
    @IBOutlet weak var milestoneTextField: UITextField!
    @IBOutlet weak var referenceButton: UIButton!
    @IBOutlet weak var scheduledButton: UIButton!
    @IBOutlet weak var flexibleButton: UIButton!
    @IBOutlet weak var deferredButton: UIButton!
    @IBOutlet weak var scheduledStartTextField: UITextField!
    @IBOutlet weak var scheduledEndTextField: UITextField!
    @IBOutlet weak var attendeesTextField: UITextField!
    @IBOutlet weak var dueDateTextField: UITextField!
    @IBOutlet weak var deferredToTextField: UITextField!
    @IBOutlet weak var responseDueTextField: UITextField!
    @IBOutlet weak var completionDateLabel: UILabel!
    
    @IBOutlet weak var scheduledFieldsView: UIView!
    @IBOutlet weak var flexibleFieldsView: UIView!
    @IBOutlet weak var deferredFieldsView: UIView!
    @IBOutlet weak var completionFieldsView: UIView!
    
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
    
    // MARK: - actions
    
    private func updateActivityType(type: ActivityType = .Flexible) {
        for (activityType, button) in activityTypeButtonList {
            let state = type == activityType
            let view = activityTypeViewList[activityType]
            
            button.highlighted = state
            view?.hidden = !state
        }
    }
    
    @IBAction func showReferenceView(sender: AnyObject) {
        updateActivityType(.Reference)
    }
    
    @IBAction func showScheduledView(sender: AnyObject) {
        updateActivityType(.Scheduled)
    }
    
    @IBAction func showFlexibleView(sender: AnyObject) {
        updateActivityType(.Flexible)
    }

    @IBAction func showDeferredView(sender: AnyObject) {
        updateActivityType(.Deferred)
    }
}
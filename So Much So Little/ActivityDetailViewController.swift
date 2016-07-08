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
    
    var buttonGroup: ButtonGroup!
    var viewGroup: ViewGroup!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buttonGroup = ButtonGroup(buttons: [flexibleButton, referenceButton, scheduledButton, deferredButton], backgroundColor: flexibleButton.titleColorForState(.Normal), titleColor: UIColor.whiteColor() , unSelectable: true)
        viewGroup = ViewGroup(views: [deferredFieldsView, flexibleFieldsView, scheduledFieldsView])

        if let activity = activity {
            taskTextField.text = activity.task
            
            let actualTimeboxes = activity.actual_timeboxes
            let estimatedTimeboxes = activity.estimated_timeboxes
            
            timeboxControl.pendingTimeboxes = estimatedTimeboxes as Int
            timeboxControl.completedTimeboxes = actualTimeboxes as Int
            
            switch activity.type {
            case .Deferred:
                buttonGroup.didTouchUpInside(deferredButton)
            case .Reference:
                buttonGroup.didTouchUpInside(referenceButton)
            case .Scheduled:
                buttonGroup.didTouchUpInside(scheduledButton)
            default:
                buttonGroup.didTouchUpInside(flexibleButton)
            }
        }
        
    }
    
    // MARK: - actions
    
    @IBAction func showReferenceView(sender: UIButton) {
        buttonGroup.didTouchUpInside(sender)
        viewGroup.setView(nil)
    }
    
    @IBAction func showScheduledView(sender: UIButton) {
        buttonGroup.didTouchUpInside(sender)
        viewGroup.setView(scheduledFieldsView)
    }
    
    @IBAction func showFlexibleView(sender: UIButton) {
        buttonGroup.didTouchUpInside(sender)
        viewGroup.setView(flexibleFieldsView)
    }

    @IBAction func showDeferredView(sender: UIButton) {
        buttonGroup.didTouchUpInside(sender)
        viewGroup.setView(deferredFieldsView)
    }
}
//
//  ActivityDetailView.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/30/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import UIKit

class ActivityDetailView: UIView {
    
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var timeboxControl: TimeboxControl!
    @IBOutlet weak var taskInfoTextView: UITextView!

    @IBOutlet weak var projectTextField: UITextField!
    @IBOutlet weak var milestoneTextField: UITextField!
    @IBOutlet weak var roleTextField: UITextField!

    @IBOutlet weak var referenceButton: UIButton!
    @IBOutlet weak var scheduledButton: UIButton!
    @IBOutlet weak var flexibleButton: UIButton!
    @IBOutlet weak var deferredButton: UIButton!

    @IBOutlet weak var scheduledFieldsView: UIView!
    @IBOutlet weak var scheduledStartTextField: UITextField!
    @IBOutlet weak var scheduledEndTextField: UITextField!
    @IBOutlet weak var attendeesTextField: UITextField!
    
    @IBOutlet weak var flexibleFieldsView: UIView!
    @IBOutlet weak var dueDateTextField: UILabel!
    
    @IBOutlet weak var deferredFieldsView: UIView!
    @IBOutlet weak var deferredToTextField: UITextField!
    @IBOutlet weak var responseDueByTextField: UITextField!
    
    @IBOutlet weak var completionFieldsView: UIView!
    @IBOutlet weak var completionDateTextField: UILabel!
}

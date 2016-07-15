//
//  ActivityDetailFormViewController.swift
//  So Much So Little
//
//  Created by Adland Lee on 7/9/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import Eureka
import UIKit

class ActivityDetailFormViewController: FormViewController {
    
    enum FormInput: String {
        case Task, Timeboxes, TaskInfo, Project, Milestone, Role, ActivityType, ScheduledStart,
        ScheduledEnd, Attendees, DueDate, DeferredTo, DeferredToResponseDueDate,
        Completed
    }
    
    var timeboxControlRow: TimeboxControlRow!
    
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {

        tableView = myTableView

        super.viewDidLoad()
        
        form.inlineRowHideOptions = InlineRowHideOptions.AnotherInlineRowIsShown.union(.FirstResponderChanges)
        
        form
            +++ Section()
                <<< TextRow(FormInput.Task.rawValue).cellSetup { (cell, row) in
                    cell.textField.placeholder = Activity.defaultTask
                }
        
                <<< TimeboxControlRow(FormInput.Timeboxes.rawValue)
        
                <<< TextAreaRow(FormInput.TaskInfo.rawValue) { (cell) in
                    cell.placeholder = "Description"
                }
        
                <<< TextRow(FormInput.Project.rawValue){ (cell) in
                    cell.title = "Project"
                }
            
                <<< TextRow(FormInput.Milestone.rawValue) { (cell) in
                    cell.title = "Milestone"
                }
                
                <<< TextRow(FormInput.Role.rawValue) { (cell) in
                    cell.title = "Role"
                }
        
                <<< SegmentedRow<String>(FormInput.ActivityType.rawValue) { (type) in
                    type.options = ["Reference", "Scheduled", "Flexible", "Deferred"]
                    type.value = "Flexible"
                }
            
                    // Schedule Section Fields
            
                    <<< DateTimeInlineRow(FormInput.ScheduledStart.rawValue) { (cell) in
                        cell.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ = '%@'", FormInput.ActivityType.rawValue, "Scheduled")))
                        cell.title = "Start"
                        cell.value = NSDate()
                    }
        
                    <<< DateTimeInlineRow(FormInput.ScheduledEnd.rawValue) { (cell) in
                        cell.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ = '%@'", FormInput.ActivityType.rawValue, "Scheduled")))
                        cell.title = "End"
                        cell.value = NSDate()
                    }
        
                    <<< LabelRow(FormInput.Attendees.rawValue) { (cell) in
                        cell.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ = '%@'", FormInput.ActivityType.rawValue, "Scheduled")))
                        cell.title = "Attendees"
                    }

            
                    // Flexible Section Fields
            
                    <<< DateInlineRow(FormInput.DueDate.rawValue) { (cell) in
                        cell.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ = '%@'", FormInput.ActivityType.rawValue, "Flexible")))
                        cell.title = "Due Date"
                    }
            
            
                    // Deferred Section Fields
            
                    <<< TextRow(FormInput.DeferredTo.rawValue) { (cell) in
                        cell.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ = '%@'", FormInput.ActivityType.rawValue, "Deferred")))
                        cell.title = "Deferred To:"
                    }
            
                    <<< DateInlineRow(FormInput.DeferredToResponseDueDate.rawValue) { (cell) in
                        cell.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ = '%@'", FormInput.ActivityType.rawValue, "Deferred")))
                        cell.title = "Due"
                    }


            +++ Section(FormInput.Completed.rawValue) { (section) in
                        section.tag = "CompletedSection"
                        section.hidden = true
                    }
                        <<< TextRow("Completed Date")
                        <<< DateRow("CompletedDate")
    }
    
    @IBAction func saveActivity () {
//        let timeboxControlRow = form.rowByTag("Timeboxes") as! TimeboxControlRow
        let formValues = form.values()
        let task = formValues[FormInput.Task.rawValue]
        let pendingTimeboxes = formValues[FormInput.Timeboxes.rawValue]
        let taskinfo = formValues[FormInput.TaskInfo.rawValue]
        let project = formValues[FormInput.Project.rawValue]
        let milestone = formValues[FormInput.Milestone.rawValue]
        let role = formValues[FormInput.Role.rawValue]
        let ativityType = formValues[FormInput.ActivityType.rawValue]
        let scheduledStart = formValues[FormInput.ScheduledStart.rawValue]
        let scheduledEnd = formValues[FormInput.ScheduledEnd.rawValue]
        let Attendees = formValues[FormInput.Attendees.rawValue]
        let dueDate = formValues[FormInput.DueDate.rawValue]
        let deferredTo = formValues[FormInput.DeferredTo.rawValue]
        let deferredToResponseDueDate = formValues[FormInput.DeferredToResponseDueDate.rawValue]
        let completed = formValues[FormInput.Completed.rawValue]


        print("pendingTimeboxes: \(pendingTimeboxes)")
    }
}
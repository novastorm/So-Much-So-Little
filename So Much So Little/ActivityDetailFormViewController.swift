//
//  ActivityDetailFormViewController.swift
//  So Much So Little
//
//  Created by Adland Lee on 7/9/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData
import Eureka
import UIKit

class ActivityDetailFormViewController: FormViewController {
    
    // MARK: - Properties
    
    var activity: Activity?
    
    enum FormInput: String {
        case Task, EstimatedTimeboxes, TaskInfo, Project, Milestone, Role, ActivityType, ScheduledStart,
        ScheduledEnd, Attendees, DueDate, DeferredTo, DeferredToResponseDueDate,
        Completed
    }
    
    var timeboxControlRow: TimeboxControlRow!
    
    // MARK: - Core Data convenience methods
    
    var sharedMainContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.mainContext
    }

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var myTableView: UITableView!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {

        tableView = myTableView

        super.viewDidLoad()
        
        form.inlineRowHideOptions = InlineRowHideOptions.AnotherInlineRowIsShown.union(.FirstResponderChanges)
        
        
        // MARK: Eureka! Form Setup
        
        form
            +++ Section()
                <<< TextRow(FormInput.Task.rawValue).cellSetup { (cell, row) in
                    cell.textField.placeholder = Activity.defaultTask
                }
        
                <<< TimeboxControlRow(FormInput.EstimatedTimeboxes.rawValue)
        
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
                        cell.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.ActivityType.rawValue, "Scheduled")))
                        cell.title = "Start"
                        cell.value = NSDate()
                    }
        
                    <<< DateTimeInlineRow(FormInput.ScheduledEnd.rawValue) { (cell) in
                        cell.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.ActivityType.rawValue, "Scheduled")))
                        cell.title = "End"
                        cell.value = NSDate()
                    }
        
                    <<< LabelRow(FormInput.Attendees.rawValue) { (cell) in
                        cell.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.ActivityType.rawValue, "Scheduled")))
                        cell.title = "Attendees"
                    }

            
                    // Flexible Section Fields
            
                    <<< DateInlineRow(FormInput.DueDate.rawValue) { (cell) in
                        cell.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.ActivityType.rawValue, "Flexible")))
                        cell.title = "Due Date"
                    }
            
            
                    // Deferred Section Fields
            
                    <<< TextRow(FormInput.DeferredTo.rawValue) { (cell) in
                        cell.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.ActivityType.rawValue, "Deferred")))
                        cell.title = "Deferred To:"
                    }
            
                    <<< DateInlineRow(FormInput.DeferredToResponseDueDate.rawValue) { (cell) in
                        cell.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.ActivityType.rawValue, "Deferred")))
                        cell.title = "Due"
                    }


            +++ Section(FormInput.Completed.rawValue) { (section) in
                        section.tag = "CompletedSection"
                        section.hidden = true
                    }
                        <<< TextRow("Completed Date")
                        <<< DateRow("CompletedDate")
    }
    
    
    // MARK: - Actions
    
    @IBAction func save(sender: AnyObject) {
        print("save")
        saveActivity()
    }
    
    @IBAction func addToActivitiesToday () {
        print("Add to activities today")
        // check for activity changes
        // mark activity for today
    }
    
    @IBAction func startActivity () {
        print("start activity")
        // add to activities today
        // start activity
    }
    
    
    // MARK: - Utilities
    
    func saveActivity(askForConfirmation confirm: Bool = false) {
        
        // if activity exists
        // if confirm and data modified
        // ask for confirmation
        
        //        let timeboxControlRow = form.rowByTag("Timeboxes") as! TimeboxControlRow
        let formValues = form.values()
        print(formValues)
        
        let task = formValues[FormInput.Task.rawValue]
        let estimatedTimeboxes = formValues[FormInput.EstimatedTimeboxes.rawValue]
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
        
        
        print("estimatedTimeboxes: \(estimatedTimeboxes)")
        
        let data: [String: Any?] = [
            Activity.Keys.Task: task,
            Activity.Keys.EstimatedTimeboxes: estimatedTimeboxes
        ]
        
        let activity = Activity(data: data, context: sharedMainContext)
    
        print(activity)
    }
    
}
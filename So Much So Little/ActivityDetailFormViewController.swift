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
    
    var activity: Activity!
    
    enum FormInput: String {
        case
        Completed,
        CompletedDate,
        DeferredTo,
        DeferredToResponseDueDate,
//        DisplayOrder,
        DueDate,
        EstimatedTimeboxes,
        ScheduledEnd,
        ScheduledStart,
        Task,
        TaskInfo,
        Today,
//        TodayDisplayOrder,
        TypeValue,

        Attendees,
        Milestone,
        Project,
        Role,
        Timeboxes,

        FINAL
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
        
        if activity == nil {
            print("Create new activity")
            let entity = NSEntityDescription.entityForName(Activity.className, inManagedObjectContext: sharedMainContext)!
            
            activity = Activity(entity: entity, insertIntoManagedObjectContext: nil)
        }
        
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
        
                <<< SegmentedRow<String>(FormInput.TypeValue.rawValue) { (type) in
                    type.options = ["Reference", "Scheduled", "Flexible", "Deferred"]
                    type.value = "Flexible"
                }
            
                    // Schedule Section Fields
            
                    <<< DateTimeInlineRow(FormInput.ScheduledStart.rawValue) { (cell) in
                        cell.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.TypeValue.rawValue, "Scheduled")))
                        cell.title = "Start"
                        cell.value = NSDate()
                    }
        
                    <<< DateTimeInlineRow(FormInput.ScheduledEnd.rawValue) { (cell) in
                        cell.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.TypeValue.rawValue, "Scheduled")))
                        cell.title = "End"
                        cell.value = NSDate()
                    }
        
                    <<< LabelRow(FormInput.Attendees.rawValue) { (cell) in
                        cell.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.TypeValue.rawValue, "Scheduled")))
                        cell.title = "Attendees"
                    }

            
                    // Flexible Section Fields
            
                    <<< DateInlineRow(FormInput.DueDate.rawValue) { (cell) in
                        cell.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.TypeValue.rawValue, "Flexible")))
                        cell.title = "Due Date"
                    }
            
            
                    // Deferred Section Fields
            
                    <<< TextRow(FormInput.DeferredTo.rawValue) { (cell) in
                        cell.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.TypeValue.rawValue, "Deferred")))
                        cell.title = "Deferred To:"
                    }
            
                    <<< DateInlineRow(FormInput.DeferredToResponseDueDate.rawValue) { (cell) in
                        cell.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.TypeValue.rawValue, "Deferred")))
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
        if activity.managedObjectContext == nil {
            sharedMainContext.insertObject(activity)
        }
        
        //        let timeboxControlRow = form.rowByTag("Timeboxes") as! TimeboxControlRow
        let formValues = form.values()
        print(formValues)
        
        let completed = formValues[FormInput.Completed.rawValue]
        let completedDate = formValues[FormInput.CompletedDate.rawValue]
        let deferredTo = formValues[FormInput.DeferredTo.rawValue]
        let deferredToResponseDueDate = formValues[FormInput.DeferredToResponseDueDate.rawValue]
//        let displayOrder
        let dueDate = formValues[FormInput.DueDate.rawValue]
        let estimatedTimeboxes = formValues[FormInput.EstimatedTimeboxes.rawValue]
        let scheduledEnd = formValues[FormInput.ScheduledEnd.rawValue]
        let scheduledStart = formValues[FormInput.ScheduledStart.rawValue]
        let task = formValues[FormInput.Task.rawValue] as? Activity.TaskType ?? Activity.defaultTask
        let taskInfo = formValues[FormInput.TaskInfo.rawValue]
        let today = formValues[FormInput.Today.rawValue]
//        let todayDisplayOrder
        let typeValue = formValues[FormInput.TypeValue.rawValue]
        

        let attendees = formValues[FormInput.Attendees.rawValue]
        let milestone = formValues[FormInput.Milestone.rawValue]
        let project = formValues[FormInput.Project.rawValue]
        let role = formValues[FormInput.Role.rawValue]
//        let timeboxes
        
        print("estimatedTimeboxes: \(estimatedTimeboxes)")
        
        activity.task = task
    
        print(activity)
        
        CoreDataStackManager.saveMainContext()
    }
    
}
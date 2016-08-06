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
        
        // MARK: Eureka! Form Setup

        form.inlineRowHideOptions = InlineRowHideOptions.AnotherInlineRowIsShown.union(.FirstResponderChanges)
        
        form
            +++ Section()
                <<< TextRow(FormInput.Task.rawValue) { (row) in
                    
                    row.value = self.activity?.task ?? Activity.defaultTask
                    row.placeholder = Activity.defaultTask
                }
        
                <<< TimeboxControlRow(FormInput.EstimatedTimeboxes.rawValue)
        
                <<< TextAreaRow(FormInput.TaskInfo.rawValue) { (row) in
                    row.value = self.activity?.task_info
                    row.placeholder = "Description"
                }
        
                <<< TextRow(FormInput.Project.rawValue){ (row) in
                    row.title = "Project"
                }
            
                <<< TextRow(FormInput.Milestone.rawValue) { (row) in
                    row.title = "Milestone"
                }
                
                <<< TextRow(FormInput.Role.rawValue) { (row) in
                    row.title = "Role"
                }
        
                <<< SegmentedRow<String>(FormInput.TypeValue.rawValue) { (type) in
                    type.options = ["Reference", "Scheduled", "Flexible", "Deferred"]
                    type.value = "Flexible"
                }
            
                    // Schedule Section Fields
            
                    <<< DateTimeInlineRow(FormInput.ScheduledStart.rawValue) { (row) in
                        row.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.TypeValue.rawValue, "Scheduled")))
                        row.title = "Start"
                        row.value = NSDate()
                    }
        
                    <<< DateTimeInlineRow(FormInput.ScheduledEnd.rawValue) { (row) in
                        row.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.TypeValue.rawValue, "Scheduled")))
                        row.title = "End"
                        row.value = NSDate()
                    }
        
                    <<< LabelRow(FormInput.Attendees.rawValue) { (row) in
                        row.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.TypeValue.rawValue, "Scheduled")))
                        row.title = "Attendees"
                    }

            
                    // Flexible Section Fields
            
                    <<< DateInlineRow(FormInput.DueDate.rawValue) { (row) in
                        row.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.TypeValue.rawValue, "Flexible")))
                        row.title = "Due Date"
                    }
            
            
                    // Deferred Section Fields
            
                    <<< TextRow(FormInput.DeferredTo.rawValue) { (row) in
                        row.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.TypeValue.rawValue, "Deferred")))
                        row.title = "Deferred To:"
                    }
            
                    <<< DateInlineRow(FormInput.DeferredToResponseDueDate.rawValue) { (row) in
                        row.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.TypeValue.rawValue, "Deferred")))
                        row.title = "Due"
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
        
        let completed = formValues[FormInput.Completed.rawValue]
        let completedDate = formValues[FormInput.CompletedDate.rawValue]
        let deferredTo = formValues[FormInput.DeferredTo.rawValue]
        let deferredToResponseDueDate = formValues[FormInput.DeferredToResponseDueDate.rawValue]
//        let displayOrder
        let dueDate = formValues[FormInput.DueDate.rawValue]
        let estimatedTimeboxes = formValues[FormInput.EstimatedTimeboxes.rawValue]
        let scheduledEnd = formValues[FormInput.ScheduledEnd.rawValue]
        let scheduledStart = formValues[FormInput.ScheduledStart.rawValue]
//        let task = formValues[FormInput.Task.rawValue] as? Activity.TaskType ?? Activity.defaultTask
        let taskInfo = formValues[FormInput.TaskInfo.rawValue]
        let today = formValues[FormInput.Today.rawValue]
//        let todayDisplayOrder
        let typeValue = formValues[FormInput.TypeValue.rawValue]
        

        let attendees = formValues[FormInput.Attendees.rawValue]
        let milestone = formValues[FormInput.Milestone.rawValue]
        let project = formValues[FormInput.Project.rawValue]
        let role = formValues[FormInput.Role.rawValue]
//        let timeboxes
        
        
        if activity == nil {
            activity = Activity(inContext: sharedMainContext)
        }
        

        activity!.task = formValues[FormInput.Task.rawValue] as! Activity.TaskType
        activity!.task_info = formValues[FormInput.TaskInfo.rawValue] as? Activity.TaskInfoType
//        activity.completed = completed
//        activity.completed_date = completedDate
        
        print(activity!.managedObjectContext)
        print(activity!)
        
        CoreDataStackManager.saveMainContext()
    }    
}
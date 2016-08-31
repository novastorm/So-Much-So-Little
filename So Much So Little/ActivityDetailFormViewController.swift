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
        Kind,
        ScheduledEnd,
        ScheduledStart,
        Task,
        TaskInfo,
        Today,
//        TodayDisplayOrder,

        Attendees,
        Milestone,
        Project,
        Role,
        Timeboxes
    }
    
    var timeboxControlRow: TimeboxControlRow!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var myTableView: UITableView!

    
    // MARK: - Core Data convenience methods
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.mainContext
    }

    lazy var temporaryContext: NSManagedObjectContext = {
        return CoreDataStackManager.getTemporaryContext(withName: "TempActivity")
    }()
    
    func saveTemporaryContext() {
        CoreDataStackManager.saveTemporaryContext(temporaryContext)
    }
    
    lazy var projectFRC: NSFetchedResultsController = {
        let fetchRequest = Project.fetchRequest
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return frc
    }()

    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {

        tableView = myTableView

        super.viewDidLoad()
        
        temporaryContext.performBlockAndWait {
            if self.activity == nil {
                self.activity = Activity(context: self.temporaryContext)
            }

            self.activity = self.temporaryContext.objectWithID(self.activity.objectID) as! Activity
        }
        
        try! projectFRC.performFetch()
        
        // MARK: Eureka! Form Setup

        form.inlineRowHideOptions = InlineRowHideOptions.AnotherInlineRowIsShown.union(.FirstResponderChanges)
        
        form
            +++ Section()
                <<< TextRow(FormInput.Task.rawValue) { (row) in
                    row.placeholder = Activity.defaultTask
                    temporaryContext.performBlockAndWait {
                        row.value = self.activity.task
                    }
                }
        
                <<< TimeboxControlRow(FormInput.EstimatedTimeboxes.rawValue)
        
                <<< TextAreaRow(FormInput.TaskInfo.rawValue) { (row) in
                    row.placeholder = "Description"
                    temporaryContext.performBlockAndWait {
                        row.value = self.activity.task_info
                    }
                }
        
                <<< PushRow<Project>(FormInput.Project.rawValue) { (row) in
                    row.title = "Project"
                    
                    // get project from temporary context into main context for display
                    temporaryContext.performBlockAndWait {
                        if let project = self.activity.project {
                            let projectInContext = self.sharedContext.objectWithID(project.objectID) as! Project
                            row.value = projectInContext
                        }
                    }
                    if row.value != nil {
                        row.displayValueFor = { (value) in
                            return value?.label
                        }
                    }
                }.onCellSelection { (cell, row) in
                    try! self.projectFRC.performFetch()
                    row.options.removeAll()
                    row.options = self.projectFRC.fetchedObjects as! [Project]

                    row.displayValueFor = { (value) in
                        return value?.label
                    }
                }.onChange { (row) in
                    if row.value != nil {
                        row.displayValueFor = { (value) in
                            return value?.label
                        }
                    }
                    
                    
                    self.temporaryContext.performBlockAndWait {
                        let project = self.temporaryContext.objectWithID(row.value!.objectID) as! Project
                        self.activity.project = project
                    }
                }
        
                <<< SegmentedRow<String>(FormInput.Kind.rawValue) { (type) in
                    type.options = [
                        String(Activity.Kind.Reference),
                        String(Activity.Kind.Scheduled),
                        String(Activity.Kind.Flexible),
                        String(Activity.Kind.Deferred)
                    ]
                    temporaryContext.performBlockAndWait {
                        print(String(self.activity.kind))
                        type.value = String(self.activity.kind)
                    }
                }
        
                // Schedule Section Fields
        
                <<< DateTimeInlineRow(FormInput.ScheduledStart.rawValue) { (row) in
                    row.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.Kind.rawValue, String(Activity.Kind.Scheduled))))
                    row.title = "Start"
                    row.value = NSDate()
                    temporaryContext.performBlockAndWait {
                        if let scheduledStart = self.activity.scheduled_start {
                            print(scheduledStart)
                        }
                    }
                }
    
                <<< DateTimeInlineRow(FormInput.ScheduledEnd.rawValue) { (row) in
                    row.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.Kind.rawValue, String(Activity.Kind.Scheduled))))
                    row.title = "End"
                    row.value = NSDate()
                    temporaryContext.performBlockAndWait {
                        if let scheduledEnd = self.activity.scheduled_end {
                            print(scheduledEnd)
                        }
                    }
                }
    
                <<< LabelRow(FormInput.Attendees.rawValue) { (row) in
                    row.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.Kind.rawValue, String(Activity.Kind.Scheduled))))
                    row.title = "Attendees"
                    temporaryContext.performBlockAndWait {
                        if let attendeesList = self.activity.attendees {
                            print(attendeesList)
                        }
                    }
                }

        
                // Flexible Section Fields
        
                <<< DateInlineRow(FormInput.DueDate.rawValue) { (row) in
                    row.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.Kind.rawValue, String(Activity.Kind.Flexible))))
                    row.title = "Due Date"
                    temporaryContext.performBlockAndWait {
                        if let dueDate = self.activity.due_date {
                            print(dueDate)
                        }
                    }
                }
        
        
                // Deferred Section Fields
        
                <<< TextRow(FormInput.DeferredTo.rawValue) { (row) in
                    row.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.Kind.rawValue, String(Activity.Kind.Deferred))))
                    row.title = "Deferred To:"
                    temporaryContext.performBlockAndWait {
                        if let deferredTo = self.activity.deferred_to {
                            print(deferredTo)
                        }
                    }
                }
        
                <<< DateInlineRow(FormInput.DeferredToResponseDueDate.rawValue) { (row) in
                    row.hidden = Condition.Predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.Kind.rawValue, String(Activity.Kind.Deferred))))
                    row.title = "Due"
                    temporaryContext.performBlockAndWait {
                        if let deferredToResponseDueDate = self.activity.deferred_to_response_due_date {
                            print(deferredToResponseDueDate)
                        }
                    }
                }

            +++ Section(FormInput.Completed.rawValue) { (section) in
                    section.tag = "CompletedSection"
                    temporaryContext.performBlockAndWait {
                        section.hidden = Condition(booleanLiteral: !self.activity.completed)
                    }
                }
                <<< TextRow("Completed Date")
                <<< DateRow("CompletedDate") { (row) in
                    temporaryContext.performBlockAndWait {
                        if let completedDate = self.activity.completed_date {
                            print(completedDate)
                        }
                    }
                }
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
        // save activity
        // start activity
    }
    
    
    // MARK: - Utilities
    
    func saveActivity() {
        print("Save Activity")
        
        let formValues = form.values()
        
        temporaryContext.performBlock { 
            self.activity.completed = formValues[FormInput.Completed.rawValue] as? Activity.CompletedType ?? false
            self.activity.completed_date = formValues[FormInput.CompletedDate.rawValue] as? Activity.CompletedDateType
            self.activity.deferred_to = formValues[FormInput.DeferredTo.rawValue] as? Activity.DeferredToType
            self.activity.deferred_to_response_due_date = formValues[FormInput.DeferredToResponseDueDate.rawValue] as? Activity.DeferredToResponseDueDateType
            self.activity.due_date = formValues[FormInput.DueDate.rawValue] as? Activity.DueDateType
            self.activity.estimated_timeboxes = formValues[FormInput.EstimatedTimeboxes.rawValue] as? Activity.EstimatedTimeboxesType ?? 0
            self.activity.kind = Activity.Kind.fromString(formValues[FormInput.Kind.rawValue] as! String)!
            self.activity.scheduled_end = formValues[FormInput.ScheduledEnd.rawValue] as? Activity.ScheduledEndType
            self.activity.scheduled_start = formValues[FormInput.ScheduledStart.rawValue] as? Activity.ScheduledStartType
            self.activity.task = formValues[FormInput.Task.rawValue] as! Activity.TaskType
            self.activity.task_info = formValues[FormInput.TaskInfo.rawValue] as? Activity.TaskInfoType
            self.activity.today = formValues[FormInput.Today.rawValue] as? Activity.TodayType ?? false
            
            
            self.saveTemporaryContext()
        }
        
    }
    
    func flagForToday(flag: Bool = true) {
        self.temporaryContext.performBlockAndWait { 
            self.activity.today = flag
        }
    }
}


extension ActivityDetailFormViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("**** CHANGE DETECTED ****")
    }
}
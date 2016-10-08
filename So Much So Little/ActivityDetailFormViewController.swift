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

        Project,
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
    
    lazy var projectFRC: NSFetchedResultsController<Project> = {
        let fetchRequest = Project.fetchRequest() as! NSFetchRequest<Project>
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Project.Keys.Label, ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return frc
    }()

    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {

        tableView = myTableView

        super.viewDidLoad()
        
        temporaryContext.performAndWait {
            if self.activity == nil {
                self.activity = Activity(context: self.temporaryContext)
            }

            self.activity = self.temporaryContext.object(with: self.activity.objectID) as! Activity
        }
        
        
        // MARK: Eureka! Form Setup

        form.inlineRowHideOptions = InlineRowHideOptions.AnotherInlineRowIsShown.union(.FirstResponderChanges)
        
        form
            +++ Section()
                <<< TextRow(FormInput.Task.rawValue) { (row) in
                    row.placeholder = Activity.defaultTask
                    temporaryContext.performAndWait {
                        row.value = self.activity.task
                    }
                }
        
                <<< TimeboxControlRow(FormInput.EstimatedTimeboxes.rawValue)
        
                <<< TextAreaRow(FormInput.TaskInfo.rawValue) { (row) in
                    row.placeholder = "Description"
                    temporaryContext.performAndWait {
                        row.value = self.activity.task_info
                    }
                }
        
                <<< PushRow<Project>(FormInput.Project.rawValue) { (row) in
                    row.title = "Project"
                    
                    // get project from temporary context into main context for display
                    temporaryContext.performAndWait {
                        if let project = self.activity.project {
                            let projectInContext = self.sharedContext.object(with: project.objectID) as! Project
                            row.value = projectInContext
                        }
                    }
                    row.displayValueFor = { (value) in
                        return value?.label
                    }
                }.onCellSelection { (cell, row) in
                    try! self.projectFRC.performFetch()
                    row.options = self.projectFRC.fetchedObjects!
                }.onChange { (row) in
                    self.temporaryContext.performAndWait {
                        
                        guard row.value != nil else {
                            self.activity.project = nil
                            return
                        }
                        
                        self.activity.project = self.temporaryContext.object(with: row.value!.objectID) as? Project
                    }
                }.onPresent { (from, to) in
                    to.selectableRowCellUpdate = { (cell, row) in
                        if let value = row.selectableValue {
                            row.title = value.label
                        }
                    }
                }
        
                <<< SegmentedRow<String>(FormInput.Kind.rawValue) { (type) in
                    type.options = [
                        String(describing: Activity.Kind.reference),
                        String(describing: Activity.Kind.scheduled),
                        String(describing: Activity.Kind.flexible),
                        String(describing: Activity.Kind.deferred)
                    ]
                    temporaryContext.performAndWait {
                        print(String(describing: self.activity.kind))
                        type.value = String(describing: self.activity.kind)
                    }
                }
        
                // Schedule Section Fields
        
                <<< DateTimeInlineRow(FormInput.ScheduledStart.rawValue) { (row) in
                    row.hidden = Condition.predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.Kind.rawValue, String(describing: Activity.Kind.scheduled))))
                    row.title = "Start"
                    row.value = Date()
                    temporaryContext.performAndWait {
                        if let scheduledStart = self.activity.scheduled_start {
                            print(scheduledStart)
                        }
                    }
                }
    
                <<< DateTimeInlineRow(FormInput.ScheduledEnd.rawValue) { (row) in
                    row.hidden = Condition.predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.Kind.rawValue, String(describing: Activity.Kind.scheduled))))
                    row.title = "End"
                    row.value = Date()
                    temporaryContext.performAndWait {
                        if let scheduledEnd = self.activity.scheduled_end {
                            print(scheduledEnd)
                        }
                    }
                }
            
        
                // Flexible Section Fields
        
                <<< DateInlineRow(FormInput.DueDate.rawValue) { (row) in
                    row.hidden = Condition.predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.Kind.rawValue, String(describing: Activity.Kind.flexible))))
                    row.title = "Due Date"
                    temporaryContext.performAndWait {
                        if let dueDate = self.activity.due_date {
                            print(dueDate)
                        }
                    }
                }
        
        
                // Deferred Section Fields
        
                <<< TextRow(FormInput.DeferredTo.rawValue) { (row) in
                    row.hidden = Condition.predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.Kind.rawValue, String(describing: Activity.Kind.deferred))))
                    row.title = "Deferred To:"
                    temporaryContext.performAndWait {
                        if let deferredTo = self.activity.deferred_to {
                            print(deferredTo)
                        }
                    }
                }
        
                <<< DateInlineRow(FormInput.DeferredToResponseDueDate.rawValue) { (row) in
                    row.hidden = Condition.predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.Kind.rawValue, String(describing: Activity.Kind.deferred))))
                    row.title = "Due"
                    temporaryContext.performAndWait {
                        if let deferredToResponseDueDate = self.activity.deferred_to_response_due_date {
                            print(deferredToResponseDueDate)
                        }
                    }
                }

            +++ Section(FormInput.Completed.rawValue) { (section) in
                    section.tag = "CompletedSection"
                    temporaryContext.performAndWait {
                        section.hidden = Condition(booleanLiteral: !self.activity.completed)
                    }
                }
                <<< TextRow("Completed Date")
                <<< DateRow("CompletedDate") { (row) in
                    temporaryContext.performAndWait {
                        if let completedDate = self.activity.completed_date {
                            print(completedDate)
                        }
                    }
                }
    }
    
    
    // MARK: - Actions
    
    @IBAction func save(_ sender: AnyObject) {
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
        let formValues = form.values()
        
        temporaryContext.perform { 
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
    
    func flagForToday(_ flag: Bool = true) {
        self.temporaryContext.performAndWait { 
            self.activity.today = flag
        }
    }
}


extension ActivityDetailFormViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("**** CHANGE DETECTED ****")
    }
}

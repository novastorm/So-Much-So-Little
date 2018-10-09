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

struct ActivityDetailFormViewControllerDependencies {
    
    var coreDataStack: CoreDataStack!
    
    init(
        coreDataStack: CoreDataStack = (UIApplication.shared.delegate as! AppDelegate).coreDataStack
        ) {
        self.coreDataStack = coreDataStack
    }
}

class ActivityDetailFormViewController: FormViewController {
    
    // MARK: - Properties

    let dependencies: ActivityDetailFormViewControllerDependencies!
    
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
        Info,
        Kind,
        ScheduledEnd,
        ScheduledStart,
        Name,
        Today,
//        TodayDisplayOrder,

        Project,
        Timeboxes,
        
        Delete
    }
    
    var timeboxControlRow: TimeboxControlRow!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var myTableView: UITableView!

    
    // MARK: - Core Data convenience methods
    
    var coreDataStack: CoreDataStack {
        return dependencies.coreDataStack
    }
    
    var mainContext: NSManagedObjectContext {
        return coreDataStack.mainContext
    }

    lazy var temporaryContext: NSManagedObjectContext = {
        return coreDataStack.getTemporaryContext(withName: "TempActivity")
    }()
    
    func saveTemporaryContext() {
        coreDataStack.saveTemporaryContext(temporaryContext)
    }
    
    lazy var projectFRC: NSFetchedResultsController<Project> = {
        let fetchRequest = Project.fetchRequest() as NSFetchRequest<Project>
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Project.Keys.Name, ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return frc
    }()

    
    // MARK: - View Life Cycle
    
    init?(coder aDecoder: NSCoder?, dependencies: ActivityDetailFormViewControllerDependencies) {
        self.dependencies = dependencies
        if let aDecoder = aDecoder {
            super.init(coder: aDecoder)
        }
        else {
            super.init()
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(
            coder: aDecoder,
            dependencies: ActivityDetailFormViewControllerDependencies()
            )
    }
    
    override func viewDidLoad() {

        tableView = myTableView

        super.viewDidLoad()
        
        temporaryContext.performAndWait {
            if self.activity == nil {
                self.activity = Activity(insertInto: self.temporaryContext)
            }

            self.activity = self.temporaryContext.object(with: self.activity.objectID) as? Activity
        }
        
        
        // MARK: Eureka! Form Setup

        form.inlineRowHideOptions = InlineRowHideOptions.AnotherInlineRowIsShown.union(.FirstResponderChanges)
        
        form
            
        /******************************************************************/
        
        +++ Section()
        
        /******************************************************************/

        <<< TextRow(FormInput.Name.rawValue) { (row) in
            row.placeholder = Activity.defaultName
            temporaryContext.performAndWait {
                row.value = self.activity.name
            }
        }
        
        <<< TimeboxControlRow(FormInput.EstimatedTimeboxes.rawValue)
        
        <<< TextAreaRow(FormInput.Info.rawValue) { (row) in
            row.placeholder = "Description"
            temporaryContext.performAndWait {
                row.value = self.activity.info
            }
        }
        
        <<< PushRow<Project>(FormInput.Project.rawValue) { (row) in
            row.title = "Project"
            
            // get project from temporary context into main context for display
            temporaryContext.performAndWait {
                if let project = self.activity.project {
                    let projectInContext = self.mainContext.object(with: project.objectID) as! Project
                    row.value = projectInContext
                }
            }
            row.displayValueFor = { (project) in
                return project?.name
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
                if let project = row.selectableValue {
                    row.title = project.name
                }
            }
        }
        
        <<< SegmentedRow<String>(FormInput.Kind.rawValue) { (type) in
            type.options = [
                String(describing: Activity.Kind.reference).capitalized,
                String(describing: Activity.Kind.scheduled).capitalized,
                String(describing: Activity.Kind.flexible).capitalized,
                String(describing: Activity.Kind.deferred).capitalized
            ]
            temporaryContext.performAndWait {
//                print(String(describing: self.activity.kind))
                type.value = String(describing: self.activity.kind).capitalized
            }
        }
        
        // Schedule Section Fields
        
        <<< DateTimeInlineRow(FormInput.ScheduledStart.rawValue) { (row) in
            row.hidden = Condition.predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.Kind.rawValue, String(describing: Activity.Kind.scheduled).capitalized)))
            row.title = "Start"
            row.value = Date()
            temporaryContext.performAndWait {
                if let scheduledStart = self.activity.scheduledStart {
                    print(scheduledStart)
                }
            }
        }
        
        <<< DateTimeInlineRow(FormInput.ScheduledEnd.rawValue) { (row) in
            row.hidden = Condition.predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.Kind.rawValue, String(describing: Activity.Kind.scheduled).capitalized)))
            row.title = "End"
            row.value = Date()
            temporaryContext.performAndWait {
                if let scheduledEnd = self.activity.scheduledEnd {
                    print(scheduledEnd)
                }
            }
        }
        
        
        // Flexible Section Fields
        
        <<< DateInlineRow(FormInput.DueDate.rawValue) { (row) in
            row.hidden = Condition.predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.Kind.rawValue, String(describing: Activity.Kind.flexible).capitalized)))
            row.title = "Due Date"
            temporaryContext.performAndWait {
                if let dueDate = self.activity.dueDate {
                    print(dueDate)
                }
            }
        }
        
        
        // Deferred Section Fields
        
        <<< TextRow(FormInput.DeferredTo.rawValue) { (row) in
            row.hidden = Condition.predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.Kind.rawValue, String(describing: Activity.Kind.deferred).capitalized)))
            row.title = "Deferred To:"
            temporaryContext.performAndWait {
                if let deferredTo = self.activity.deferredTo {
                    print(deferredTo)
                }
            }
        }
        
        <<< DateInlineRow(FormInput.DeferredToResponseDueDate.rawValue) { (row) in
            row.hidden = Condition.predicate(NSPredicate(format: String(format: "$%@ != '%@'", FormInput.Kind.rawValue, String(describing: Activity.Kind.deferred))))
            row.title = "Due"
            temporaryContext.performAndWait {
                if let deferredToResponseDueDate = self.activity.deferredToResponseDueDate {
                    print(deferredToResponseDueDate)
                }
            }
        }
        
        <<< DateRow(FormInput.CompletedDate.rawValue) { (row) in
            temporaryContext.performAndWait {
                row.hidden = Condition(booleanLiteral: !self.activity.completed)
                row.title = "Completed"
                row.disabled = true
                if let completedDate = self.activity.completedDate {
                    print(completedDate)
                }
            }
        }
        
        <<< ButtonRow(FormInput.Delete.rawValue) { (row) in
            temporaryContext.performAndWait {
                row.hidden = Condition(booleanLiteral: self.activity.objectID.isTemporaryID)
                row.title = "Delete"
            }
        }.onCellSelection { (cell, row) in
//            print("Delete button pressed")
            self.deleteActivity()
        }
    
    }
    
    
    // MARK: - Actions
    
    @IBAction func save(_ sender: AnyObject) {
        if !ConnectionMonitor.shared.isConnectedToNetwork() {
            showNetworkAlert(self)
        }
        saveActivity()
    }
    
    @IBAction func addToActivitiesToday () {
        print("Add to activities today")
        // check for activity changes
        // mark activity for today
        flagForToday()
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
            self.activity.completedDate = formValues[FormInput.CompletedDate.rawValue] as? Activity.CompletedDateType
            self.activity.deferredTo = formValues[FormInput.DeferredTo.rawValue] as? Activity.DeferredToType
            self.activity.deferredToResponseDueDate = formValues[FormInput.DeferredToResponseDueDate.rawValue] as? Activity.DeferredToResponseDueDateType
            self.activity.dueDate = formValues[FormInput.DueDate.rawValue] as? Activity.DueDateType
            self.activity.estimatedTimeboxes = formValues[FormInput.EstimatedTimeboxes.rawValue] as? Activity.EstimatedTimeboxesType ?? 0
            self.activity.info = formValues[FormInput.Info.rawValue] as? Activity.InfoType
            self.activity.kind = Activity.Kind.fromString((formValues[FormInput.Kind.rawValue] as! String).lowercased())!
            self.activity.scheduledEnd = formValues[FormInput.ScheduledEnd.rawValue] as? Activity.ScheduledEndType
            self.activity.scheduledStart = formValues[FormInput.ScheduledStart.rawValue] as? Activity.ScheduledStartType
            self.activity.name = formValues[FormInput.Name.rawValue] as! Activity.NameType
            self.activity.today = formValues[FormInput.Today.rawValue] as? Activity.TodayType ?? false
            
            self.saveTemporaryContext()
            
            try! self.temporaryContext.obtainPermanentIDs(for: [self.activity])
            performUIUpdatesOnMain {
                self.tableView.reloadData()
            }
        }
        
    }
    
    func deleteActivity() {
        temporaryContext.perform {
            self.temporaryContext.delete(self.activity)
            self.saveTemporaryContext()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func flagForToday(_ flag: Bool = true) {
        self.temporaryContext.performAndWait { 
            self.activity.today = flag
            self.saveTemporaryContext()
        }
    }
}


extension ActivityDetailFormViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("**** CHANGE DETECTED ****")
    }
}

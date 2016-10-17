//
//  ProjectDetailFormViewController.swift
//  So Much So Little
//
//  Created by Adland Lee on 8/11/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData
import Eureka
import UIKit

class ProjectDetailFormViewController: FormViewController {
    
    // MARK: - Properties
    
    var project: Project!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!

    enum FormInput: String {
        case
        Active,
        Completed,
        DisplayOrder,
        DueDate,
        Info,
        Name,
//        HasParentProject,
//        HasSubproject,
        
        Activities
//        Milestones,
//        Parent,
//        Subprojects,
//        Roles
    }
    
    // MARK: - Core Data convenience methods
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.mainContext
    }
    
    lazy var temporaryContext: NSManagedObjectContext = {
        return CoreDataStackManager.getTemporaryContext(withName: "TempProject")
    }()
    
    func saveTemporaryContext() {
        CoreDataStackManager.saveTemporaryContext(temporaryContext)
    }
    
    lazy var activityFRC: NSFetchedResultsController<Activity> = {
        let fetchRequest = Activity.fetchRequest() as NSFetchRequest<Activity>
        fetchRequest.predicate = NSPredicate(format: "project == %@", self.project)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: Activity.Keys.Completed, ascending: true)
        ]
        let frc = NSFetchedResultsController<Activity>(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return frc
    }()
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        temporaryContext.performAndWait { 
            if self.project == nil {
                self.project = Project(context: self.temporaryContext)
            }
            
            self.project = self.temporaryContext.object(with: self.project.objectID) as! Project
        }
        
        form.inlineRowHideOptions = InlineRowHideOptions.AnotherInlineRowIsShown.union(.FirstResponderChanges)
        
        form
        +++ Section()
            <<< TextRow(FormInput.Name.rawValue) { (row) in
                row.placeholder = Project.defaultName
                temporaryContext.performAndWait {
                    row.value = self.project.name
                }
            }
            <<< SwitchRow(FormInput.Completed.rawValue) { (row) in
                row.title = "Completed"
                temporaryContext.performAndWait {
                    row.value = self.project.completed
                }
            }
            <<< DateInlineRow(FormInput.DueDate.rawValue) { (row) in
                row.title = "Due Date"
                temporaryContext.performAndWait {
                    row.value = self.project.due_date
                }
            }
            <<< TextAreaRow(FormInput.Info.rawValue) { (row) in
                row.placeholder = "Description"
                temporaryContext.performAndWait {
                    row.value = self.project.info
                }
            }
            <<< MultipleSelectorRow<Activity>(FormInput.Activities.rawValue) { (row) in
                print("Add Activity Cell")
                row.title = "Actvities"
            }.cellSetup{ (cell, row) in
                print("Activity cellSetup")
            }.cellUpdate { (cell, row) in
                print("Activity cellUpdate")
            }.onCellSelection { (cell, row) in
                print("Activity onCellSelection")
                try! self.activityFRC.performFetch()
                row.options = self.activityFRC.fetchedObjects!
            }.onChange { (row) in
                print("Activity onChange")
            }.onPresent { (from, to) in
                print("Activity onPresent")
                to.selectableRowCellSetup = { (cell, row) in
                    if let activity = row.selectableValue {
                        row.title = activity.name
                    }
                }
            }
    }
    
    
    // MARK: - Actions
    
    @IBAction func save(_ sender: AnyObject) {
        print("save")
        saveProject()
    }
    
    
    // MARK: - Utilities
    
    func saveProject() {
        print("Save Project")
        let formValues = form.values()
        
        temporaryContext.perform {
            self.project.completed = formValues[FormInput.Completed.rawValue] as! Project.CompletedType
            self.project.due_date = formValues[FormInput.DueDate.rawValue] as? Project.DueDateType
            self.project.info = formValues[FormInput.Info.rawValue] as? Project.InfoType
            self.project.name = formValues[FormInput.Name.rawValue] as! Project.NameType

            self.saveTemporaryContext()
        }
    }
}

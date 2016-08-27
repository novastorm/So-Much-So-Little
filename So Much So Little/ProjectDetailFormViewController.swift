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
    @IBOutlet weak var myTableView: UITableView!

    enum FormInput: String {
        case
        Active,
        Completed,
        DisplayOrder,
        DueDate,
        Info,
        Label,
        HasParentProject,
        HasSubproject,
        
        Activities,
        Milestones,
        Parent,
        Subprojects,
        Roles
    }
    
    // MARK: - Core Data convenience methods
    
    lazy var temporaryContext: NSManagedObjectContext = {
        return CoreDataStackManager.getTemporaryContext(withName: "TempProject")
    }()
    
    func saveTemporaryContext() {
        CoreDataStackManager.saveTemporaryContext(temporaryContext)
    }
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {

//        tableView = myTableView
        
        super.viewDidLoad()
        
        temporaryContext.performBlockAndWait { 
            if self.project == nil {
                self.project = Project(context: self.temporaryContext)
            }
            
            self.project = self.temporaryContext.objectWithID(self.project.objectID) as! Project
        }
        
        form.inlineRowHideOptions = InlineRowHideOptions.AnotherInlineRowIsShown.union(.FirstResponderChanges)
        
        form
        +++ Section()
            <<< TextRow(FormInput.Label.rawValue) { (row) in
                row.placeholder = Project.defaultLabel
                temporaryContext.performBlockAndWait {
                    row.value = self.project.label
                }
            }
            <<< SwitchRow(FormInput.Completed.rawValue) { (row) in
                row.title = "Completed"
                temporaryContext.performBlockAndWait {
                    row.value = self.project.completed
                }
            }
            <<< SwitchRow(FormInput.Active.rawValue) { (row) in
                row.title = "Active"
                temporaryContext.performBlockAndWait {
                    row.value = self.project.active
                }
            }
            <<< DateInlineRow(FormInput.DueDate.rawValue) { (row) in
//                row.hidden = Condition.Function([FormInput.Active.rawValue]) { (form) -> Bool in
//                    return ((form.rowByTag(FormInput.Active.rawValue) as? SwitchRow)?.value)!
//                    }
                row.title = "Due Date"
                temporaryContext.performBlockAndWait {
                    row.value = self.project.due_date
                }
            }
            <<< TextAreaRow(FormInput.Info.rawValue) { (row) in
                row.placeholder = "Description"
                temporaryContext.performBlockAndWait {
                    row.value = self.project.info
                }
            }
//            <<< PushRow<String>(FormInput.Roles.rawValue) { (row) in
//                let roleList = ["RR AAA", "RR BBB", "RR CCC"]
//                row.title = "Roles"
//                row.options = roleList
//                row.selectorTitle = "Choose Role"
//            }
//            <<< MultipleSelectorRow<String>(FormInput.Milestones.rawValue) { (row) in
//                let milestoneList = ["MM AAA", "MM BBB", "MM CCC"]
//                row.title = "Milestones"
//                row.options = milestoneList
//                row.selectorTitle = "Choose Milestones"
//            }
//            <<< SwitchRow(FormInput.HasParentProject.rawValue) { (row) in
//                row.title = "Parent Project Switch"
//                temporaryContext.performBlockAndWait {
//                    // true if parent project exists
//                    row.value = true
//                }
//            }
//            <<< TextRow(FormInput.Parent.rawValue) { (row) in
//                // Choose existing
//                let parentProject = ["label": "PP AAA"]
//                let isChild = !parentProject.isEmpty
//                row.hidden = Condition(booleanLiteral: isChild)
//                row.title = "Parent Project"
//                row.value = parentProject["label"]
//            }
        
    }
    
    
    // MARK: - Actions
    
    @IBAction func save(sender: AnyObject) {
        print("save")
        saveProject()
    }
    
    
    // MARK: - Utilities
    
    func saveProject() {
        print("Save Project")
        let formValues = form.values()
        
        temporaryContext.performBlock {
            self.project.completed = formValues[FormInput.Completed.rawValue] as! Project.CompletedType
            self.project.due_date = formValues[FormInput.DueDate.rawValue] as? Project.DueDateType
            self.project.info = formValues[FormInput.Info.rawValue] as? Project.InfoType
            self.project.label = formValues[FormInput.Label.rawValue] as! Project.LabelType
            self.project.active = formValues[FormInput.Active.rawValue] as! Project.ActiveType

            self.saveTemporaryContext()
        }
    }
}
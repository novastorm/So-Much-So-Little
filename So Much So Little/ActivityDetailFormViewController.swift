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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        form.inlineRowHideOptions = InlineRowHideOptions.AnotherInlineRowIsShown.union(.FirstResponderChanges)
        
        form
            +++ Section()
                <<< TextRow("Task").cellSetup { (cell, row) in
                    cell.textField.placeholder = Activity.defaultTask
                }
        
                <<< TimeboxControlRow("Timeboxes")
        
                <<< TextAreaRow("TaskInfo") { (cell) in
                    cell.placeholder = "Description"
                }
        
                <<< TextRow("Project") { (cell) in
                    cell.title = "Project"
                }
            
                <<< TextRow("Milestone") { (cell) in
                    cell.title = "Milestone"
                }
                
                <<< TextRow("Role") { (cell) in
                    cell.title = "Role"
                }
        
                <<< SegmentedRow<String>("Type") { (type) in
                    type.options = ["Reference", "Scheduled", "Flexible", "Deferred"]
                    type.value = "Flexible"
                }
            
                    // Schedule Section Fields
            
                    <<< DateTimeInlineRow("ScheduledStart") { (cell) in
                        cell.hidden = "$Type != 'Scheduled'"
                        cell.title = "Start"
                        cell.value = NSDate()
                    }
        
                    <<< DateTimeInlineRow("ScheduledEnd") { (cell) in
                        cell.hidden = "$Type != 'Scheduled'"
                        cell.title = "End"
                        cell.value = NSDate()
                    }
        
                    <<< LabelRow("Attendees") { (cell) in
                        cell.title = "Attendees"
                        cell.hidden = "$Type != 'Scheduled'"
                    }

            
                    // Flexible Section Fields
            
                    <<< DateInlineRow("DueDate") { (cell) in
                        cell.title = "Due Date"
                        cell.hidden = "$Type != 'Flexible'"
                    }
            
            
                    // Deferred Section Fields
            
                    <<< TextRow("DeferredTo") { (cell) in
                        cell.title = "Deferred To:"
                        cell.hidden = "$Type != 'Deferred'"
                    }
                    <<< DateInlineRow("DeferredToResponseDueDate") { (cell) in
                        cell.title = "Due"
                        cell.hidden = "$Type != 'Deferred'"
                    }


            +++ Section("Completed") { (section) in
                        section.tag = "CompletedSection"
                        section.hidden = true
                    }
                        <<< TextRow("Completed Date")
                        <<< DateRow("CompletedDate")
    }
    
    @IBAction func saveActivity () {
        let timeboxControlRow = form.rowByTag("Timeboxes") as! TimeboxControlRow
        let pendingTimeboxes = timeboxControlRow.value
        print("pendingTimeboxes: \(pendingTimeboxes)")
    }
}
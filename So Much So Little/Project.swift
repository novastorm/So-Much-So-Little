//
//  Project.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/20/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData
import Foundation

class Project: NSManagedObject {
    
    struct Keys {
        static let Label = "label"
        static let Info = "info"
        static let Complete = "complete"
        static let DueDate = "due_date"

        static let Activities = "activities"
        static let Milestones = "milestones"
        static let Subprojects = "subprojects"
}
}
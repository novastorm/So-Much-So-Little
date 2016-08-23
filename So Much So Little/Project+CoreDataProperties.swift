//
//  Project+CoreDataProperties.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/20/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Project {

    @NSManaged var completed: Bool
    @NSManaged var display_order: NSNumber
    @NSManaged var due_date: NSDate?
    @NSManaged var info: String?
    @NSManaged var label: String
    @NSManaged var active: Bool
    
    @NSManaged var activities: Set<Activity>?
    @NSManaged var milestones: Set<Milestone>?
    @NSManaged var parent: Project?
    @NSManaged var subprojects: Set<Project>?
    @NSManaged var roles: Set<Role>?

}

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

    @NSManaged var label: String?
    @NSManaged var info: String?
    @NSManaged var completed: NSNumber?
    @NSManaged var due_date: NSDate?
    @NSManaged var activities: NSSet?
    @NSManaged var milestones: NSSet?
    @NSManaged var subprojects: NSSet?
    @NSManaged var roles: NSSet?
    @NSManaged var parent: Project?

}

//
//  Role+CoreDataProperties.swift
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

extension Role {

    @NSManaged var label: String?
    @NSManaged var activities: NSSet?
    @NSManaged var projects: NSSet?

}

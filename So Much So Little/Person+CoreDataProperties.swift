//
//  Person+CoreDataProperties.swift
//  So Much So Little
//
//  Created by Adland Lee on 8/1/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Person {

    @NSManaged var email: String
    
    @NSManaged var activities: Set<Activity>?

}

//
//  CoreDataStackManager.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/21/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData
import Foundation

class CoreDataStackManager {
    
    static let modelName = "So_Much_So_Little"
    
    static let sharedInstance = CoreDataStack(modelName: modelName)!
    private init() {}
    
    class var context: NSManagedObjectContext {
        return sharedInstance.mainContext
    }
    
    class func getTemporaryContext(named name: String) -> NSManagedObjectContext {
        return sharedInstance.getTemporaryContext(named: name)
    }
    
    class func saveContext() {
        sharedInstance.saveMainContext()
    }

    class func autoSave(delayInSeconds: Int) {
        sharedInstance.autoSave(delayInSeconds)
    }
}
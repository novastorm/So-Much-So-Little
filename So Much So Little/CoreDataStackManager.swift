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
    
    static var mainContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.mainContext
    }
    
    static func saveMainContext() {
        CoreDataStackManager.sharedInstance.saveMainContext()
    }
    
    static func autoSave(delayInSeconds: Int) {
        CoreDataStackManager.sharedInstance.autoSave(delayInSeconds)
    }
    
    static func getTemporaryContext(withName name: String = "Temporary") -> NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.getTemporaryContext(withName: name)
    }
    
    static func saveTemporaryContext(context: NSManagedObjectContext) {
        CoreDataStackManager.sharedInstance.saveTempContext(context)
    }
}

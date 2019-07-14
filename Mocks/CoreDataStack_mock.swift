//
//  CoreDataStack_mock.swift
//  So Much So LittleTests
//
//  Created by Adland Lee on 10/8/18.
//  Copyright © 2018 Adland Lee. All rights reserved.
//

import CoreData

@testable import So_Much_So_Little

class CoreDataStack_mock: CoreDataStack {
    
    var persistentContainer: NSPersistentContainer!
    
    init?(name: String = "So_Much_So_Little") {
        self.persistentContainer = CoreDataStack_mock.createInMemoryPersistentContainer(name: name)
    }
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func getTemporaryContext(withName name: String) -> NSManagedObjectContext {
        let tempContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        tempContext.name = name
        tempContext.parent = mainContext
        
        return tempContext

    }
    
    func saveTemporaryContext(_ context: NSManagedObjectContext) {
        guard context.hasChanges else {
            return
        }
        
        context.perform {
            do {
                try context.save()
            }
            catch {
                fatalError("Error while saving temporary context \(error)")
            }
            
            self.saveMainContext()
        }
    }
    
    func getScratchContext(withName name: String) -> NSManagedObjectContext {
        let scratchContext =  NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        scratchContext.name = name
        return scratchContext

    }
    
    func clearDatabase() throws {
        let psc = persistentContainer.persistentStoreCoordinator
        let url = psc.persistentStores.first?.url
        try psc.destroyPersistentStore(at: url!, ofType: NSInMemoryStoreType, options: nil)
    }
    
    func performBackgroundBatchOperation(_ batch: @escaping BatchTask) {
        let backgroundContext = getTemporaryContext(withName: "Background")
        backgroundContext.perform(){
            batch(backgroundContext)
            
            // Save it to the parent context, so normal saving
            // can work
            do {
                try backgroundContext.save()
            }
            catch {
                fatalError("Error while saving backgroundContext: \(error)")
            }
        }
    }
    
    func saveMainContext() {
        performUIUpdatesOnMain {
            guard self.mainContext.hasChanges else {
                return
            }
            do {
                try self.mainContext.save()
            }
            catch {
                print(error)
                
                fatalError("Error while saving main context:")
            }
            
            // Save the persisting context which occurs in the background.
        }
    }
    
    func autoSave(_ interval: TimeInterval) {
        if interval > 0 {
            saveMainContext()
            
            let time = DispatchTime.now() + interval
            
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                self.autoSave(interval)
            })
        }
    }
}

extension CoreDataStack_mock {
    class func createInMemoryPersistentContainer(name: String = "So_Much_So_Little") -> NSPersistentContainer {
        let container = NSPersistentContainer(name: name)
        let description = NSPersistentStoreDescription()
        description.configuration = "Default"
        description.type = NSInMemoryStoreType
        
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores(completionHandler: { (persistentStoreDescription, error) in
            // empty
        })
        
        return container
    }
}

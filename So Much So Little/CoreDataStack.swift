//
//  CoreDataStack.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/15/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData

// MARK:  - TypeAliases
typealias BatchTask=(_ workerContext: NSManagedObjectContext) -> ()

// MARK:  - Notifications
extension Notification.Name {
    static let CoreDataStackImportingTaskDidFinishNotification = Notification.Name("CoreDataStackImportingTaskDidFinish")
}

// MARK:  - Main
class CoreDataStack {
    
    // MARK:  - Properties
    fileprivate let model : NSManagedObjectModel
    fileprivate let coordinator : NSPersistentStoreCoordinator
    fileprivate let modelURL : URL
    fileprivate let dbURL : URL
    fileprivate let persistingContext : NSManagedObjectContext
    fileprivate let backgroundContext : NSManagedObjectContext
    let mainContext : NSManagedObjectContext
    
    
    // MARK:  - Initializers
    init?(modelName: String){
        
        // Assumes the model is in the main bundle
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            print("Unable to find \(modelName) in the main bundle")
            return nil}
        
        self.modelURL = modelURL
        
        // Try to create the model from the URL
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else{
            print("unable to create a model from \(modelURL)")
            return nil
        }
        self.model = model
        
        
        // Create the store coordinator
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // Create a persistingContext (private queue) and a child one (main queue)
        // create a context and add connect it to the coordinator
        persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistingContext.name = "Persisting"
        persistingContext.persistentStoreCoordinator = coordinator
        
        mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainContext.name = "Main"
        mainContext.parent = persistingContext
        
        // Create a background context child of main context
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.name = "Background"
        backgroundContext.parent = mainContext
        
        
        // Add a SQLite store located in the documents folder
        let fm = FileManager.default
        
        guard let  docUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first else{
            print("Unable to reach the documents folder")
            return nil
        }
        
        self.dbURL = docUrl.appendingPathComponent(modelName + ".sqlite")
        
        do {
            try addStoreTo()
        }
        catch {
            print("unable to add store at \(dbURL)")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(saveMainContext), name: .CoreDataStackImportingTaskDidFinishNotification, object: nil)
    }
    
    // MARK:  - Utils
    func addStoreTo() throws {
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: nil)
    }
}

// MARK: - Temporary Context {
extension CoreDataStack {
    
    func getTemporaryContext(withName name: String = "Temporary") -> NSManagedObjectContext {
        let tempContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        tempContext.name = name
        tempContext.parent = mainContext
        
        return tempContext
    }
    
    // must call within context
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
        scratchContext.persistentStoreCoordinator = coordinator
        return scratchContext
    }
}

// MARK:  - Removing data
extension CoreDataStack  {
    
    func dropAllData() throws {
        // delete all the objects in the db. This won't delete the files, it will
        // just leave empty tables.
        try coordinator.destroyPersistentStore(at: dbURL, ofType:NSSQLiteStoreType , options: nil)
        
        try addStoreTo()
    }
}

// MARK:  - Batch processing in the background
extension CoreDataStack{
    
//    func performBackgroundBatchOperation(batch: BatchTask) {
//        
//        backgroundContext.performBlockAndWait(){
//            batch(workerContext: self.backgroundContext)
//            
//            // Save it to the parent context, so normal saving
//            // can work
//            do {
//                try self.backgroundContext.save()
//            }
//            catch {
//                fatalError("Error while saving backgroundContext: \(error)")
//            }
//        }
//    }
    
    func performAsyncBackgroundBatchOperation(_ batch: @escaping BatchTask) {
        
        backgroundContext.perform(){
            batch(self.backgroundContext)
            
            // Save it to the parent context, so normal saving
            // can work
            do {
                try self.backgroundContext.save()
            }
            catch {
                fatalError("Error while saving backgroundContext: \(error)")
            }
        }
    }
}

// MARK:  - Heavy processing in the background.
// Use this if importing a gazillion objects.
extension CoreDataStack {
    
    func performBackgroundImportingBatchOperation(_ batch: @escaping BatchTask) {
        
        // Create temp context
        let importingContext = getTemporaryContext(withName: "Importing")
        
        // Run the batch task, save the contents of the moc & notify
        importingContext.perform(){
            batch(importingContext)
            
            do {
                try importingContext.save()
            }
            catch {
                fatalError("Error saving importer moc: \(importingContext)")
            }
            
            let notificationCenter = NotificationCenter.default
            let notification = Notification(name: .CoreDataStackImportingTaskDidFinishNotification,
                object: nil)
            notificationCenter.post(notification)
        }
    }
}


// MARK:  - Save
extension CoreDataStack {
    
    @objc func saveMainContext() {
        print("\(type(of: self)) \(#function)")
        // We call this synchronously, but it's a very fast
        // operation (it doesn't hit the disk). We need to know
        // when it ends so we can call the next save (on the persisting
        // context). This last one might take some time and is done
        // in a background queue

        performUIUpdatesOnMain {
            guard self.mainContext.hasChanges else {
                return
            }
            print("\(type(of: self)) \(#function) save")
            do {
                try self.mainContext.save()
            }
            catch {
                print(error)
                
                fatalError("Error while saving main context:")
            }
            
            // now we save in the background
            
            self.savePersistingContext()
        }
    }
    
    func savePersistingContext() {
        print("\(type(of: self)) \(#function)")

        self.persistingContext.perform {
            print("\(type(of: self)) \(#function) perform")

            CloudKitClient.storeRecords(context: self.persistingContext) { (success, error) in
                self.persistingContext.perform {
                    do {
                        try self.persistingContext.save()
                    }
                    catch {
                        fatalError("Error while saving persisting context: \(error)")
                    }
                }
            }
        }
    }
    
    
    func autoSave(_ delayInSeconds : Int){
        
        if delayInSeconds > 0 {
            
            saveMainContext()
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                self.autoSave(delayInSeconds)
            })
            
        }
    }
}


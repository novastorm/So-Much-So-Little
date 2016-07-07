//
//  So_Much_So_LittleDataProviderTests.swift
//  So Much So Little Tests
//
//  Created by Adland Lee on 6/14/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import XCTest
@testable import So_Much_So_Little
import CoreData

class So_Much_So_LittleDataProviderTests: XCTestCase {
    
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var persistentStore: NSPersistentStore!
    
    func getFetchedResultsController(fetchRequest: NSFetchRequest) -> NSFetchedResultsController {
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        try! fetchedResultsController.performFetch()

        return fetchedResultsController
    }
    
    override func setUp() {
        super.setUp()
        
        managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        persistentStore = try? storeCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
    }
    
    override func tearDown() {
        managedObjectContext = nil
        try! storeCoordinator.removePersistentStore(persistentStore)
        
        super.tearDown()
    }
    
    func testThatStoreIsSetup() {
        XCTAssertNotNil(persistentStore, "No persistent store")
    }
    
    func testOneActivityInOneSection() {
        _ = Activity(task: "test activity", context: managedObjectContext)
        try! managedObjectContext.save()

        let fetchRequest = Activity.fetchRequest

        let fetchedResultsController = getFetchedResultsController(fetchRequest)
        
        let sections = fetchedResultsController.sections

        XCTAssertEqual(sections?.count, 1)
    }
    
    func testOneActivityInOneRow() {
        _ = Activity(task: "test activity", context: managedObjectContext)
        try! managedObjectContext.save()
        
        let fetchRequest = Activity.fetchRequest

        let fetchedResultsController = getFetchedResultsController(fetchRequest)

        XCTAssertEqual(fetchedResultsController.fetchedObjects?.count, 1)
    }
}

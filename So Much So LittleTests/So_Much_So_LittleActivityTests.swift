//
//  So_Much_So_LittleActivityTests.swift
//  So Much So Little Tests
//
//  Created by Adland Lee on 6/14/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import XCTest
@testable import So_Much_So_Little
import CoreData

class So_Much_So_LittleActivityTests: XCTestCase {
    
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var persistentStore: NSPersistentStore!
    
    func getFetchedResultsController(fetchRequest: NSFetchRequest) -> NSFetchedResultsController {
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        try! fetchedResultsController.performFetch()

        return fetchedResultsController
    }
    
    let mockActivityList: [String:AnyObject] = [
        "alpha": [
            Activity.Keys.Task: "Activity Alpha",
            Activity.Keys.EstimatedTimeboxes: 4,
            Activity.Keys.TaskInfo: "Alpha task info",
        ]
    ]
    
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
    
    func testOneActivity() {
        let task = "test activity"
        _ = Activity(task: task, context: managedObjectContext)
        try! managedObjectContext.save()
        
        let fetchRequest = Activity.fetchRequest

        let fetchedResultsController = getFetchedResultsController(fetchRequest)

        XCTAssertEqual(fetchedResultsController.sections?.count, 1)
        XCTAssertEqual(fetchedResultsController.fetchedObjects?.count, 1)

        let fetchedActivity = fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! Activity

        XCTAssertEqual(fetchedActivity.completed, 0, "Default Activity completed should be 0")
        XCTAssertNil(fetchedActivity.completed_date, "Default Activity completed_data should be nil")
        XCTAssertNil(fetchedActivity.deferred_to, "Default Activity deferred_to should be nil")
        XCTAssertNil(fetchedActivity.deferred_to_response_due_date, "Default Activity deferred_to_response_due_date should be nil")
        XCTAssertEqual(fetchedActivity.display_order, 0, "Default Activity display_order should be 0")
        XCTAssertNil(fetchedActivity.due_date, "Default Activity due_date should be nil")
        XCTAssertEqual(fetchedActivity.estimated_timeboxes, 0, "Default Activity estimated_timeboxes should be 0")
        XCTAssertNil(fetchedActivity.milestone, "Default Activity milestone should be nil")
        XCTAssertNil(fetchedActivity.project, "Default Activity project should be nil")
        XCTAssertEqual(fetchedActivity.roles, [], "Default Activity roles should be []")
    }
    
    func testStoreActivity() {
        let activityData = mockActivityList["alpha"] as! [String:AnyObject]
        let task = activityData[Activity.Keys.Task] as! String
        let activity = Activity(task: task, context: managedObjectContext)
        activity.estimated_timeboxes = activityData[Activity.Keys.EstimatedTimeboxes] as? Activity.EstimatedTimeboxesType
        
        let fetchRequest = Activity.fetchRequest
        let fetchedResultsController = getFetchedResultsController(fetchRequest)
        
        let fetchedActivity = fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! Activity
        
    }
}

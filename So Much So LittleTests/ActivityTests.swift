//
//  So_Much_So_LittleActivityTests.swift
//  So Much So Little Tests
//
//  Created by Adland Lee on 6/14/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import XCTest
import CoreData
@testable import So_Much_So_Little

extension Activity {
    convenience init(data: [String:Any], context: NSManagedObjectContext) {
        let task = data[Keys.Task] as? TaskType  ?? ""
        self.init(task: task, context: context)
        
        completed = data[Keys.Completed] as? CompletedType ?? false
        completed_date = data[Keys.CompletedDate] as? CompletedDateType
        deferred_to = data[Keys.DeferredTo] as? DeferredToType
        deferred_to_response_due_date = data[Keys.DeferredToResponseDueDate] as? DeferredToResponseDueDateType
        display_order = data[Keys.DisplayOrder] as? DisplayOrderType ?? 0
        due_date = data[Keys.DueDate] as? DueDateType
        estimated_timeboxes = data[Keys.EstimatedTimeboxes] as? EstimatedTimeboxesType ?? 0
        kind = data[Keys.Kind] as? Kind ?? .flexible
        scheduled_end = data[Keys.ScheduledEnd] as? ScheduledEndType
        scheduled_start = data[Keys.ScheduledStart] as? ScheduledStartType
        task_info = data[Keys.TaskInfo] as? TaskInfoType
        today = data[Keys.Today] as? TodayType ?? false
        today_display_order = data[Keys.TodayDisplayOrder] as? TodayDisplayOrderType ?? 0
        
    }
}

class ActivityTests: XCTestCase {
    
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var persistentStore: NSPersistentStore!
    
    func getFetchedResultsController(_ fetchRequest: NSFetchRequest<Activity>) -> NSFetchedResultsController<Activity> {
        let fetchedResultsController = NSFetchedResultsController<Activity>(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)

        return fetchedResultsController
    }
    
    func getActivityFetchRequest() -> NSFetchRequest<Activity> {
        let fetchRequest = NSFetchRequest<Activity>.init(entityName: "Activity")
        fetchRequest.sortDescriptors = []
        
        return fetchRequest
    }
    
    let mockActivityList: [String:[String:Any]] = [
        "alpha": [
            Activity.Keys.Task: "Activity Alpha",
            Activity.Keys.EstimatedTimeboxes: 4,
            Activity.Keys.TaskInfo: "Alpha task info",
        ],
        "bravo": [
            Activity.Keys.Task: "Activity Bravo",
            Activity.Keys.EstimatedTimeboxes: 2,
            Activity.Keys.Today: true,
            Activity.Keys.Completed: true
        ],
        "charlie": [
            Activity.Keys.Task: "Activity Charlie",
        ],
        "delta": [
            Activity.Keys.Task: "Activity Delta",
            Activity.Keys.Completed: true
        ],
        "echo": [
            Activity.Keys.Task: "Activity Echo",
            Activity.Keys.EstimatedTimeboxes: 4,
            Activity.Keys.Today: true,
        ]
    ]
    
    override func setUp() {
        super.setUp()
        
        managedObjectModel = NSManagedObjectModel.mergedModel(from: nil)
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        do {
            persistentStore = try storeCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        }
        catch {
            print(error)
            abort()
        }
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
    }
    
    override func tearDown() {
        managedObjectContext = nil
        try! storeCoordinator.remove(persistentStore)
        
        super.tearDown()
    }
    
    func testIncompleteActivityData() {
        let defaultActivity = Activity(context: managedObjectContext)
        XCTAssertEqual(defaultActivity.task, Activity.defaultTask)
        
        let blankActivity = Activity(context: managedObjectContext)
        XCTAssertEqual(blankActivity.task, Activity.defaultTask)
    }
    
    func testOneActivity() {
        let task = "test activity"
        let activity = Activity(task: task, context: managedObjectContext)
        try! managedObjectContext.save()
        
        let fetchRequest = getActivityFetchRequest()

        let fetchedResultsController = getFetchedResultsController(fetchRequest)

        try! fetchedResultsController.performFetch()

        XCTAssertEqual(fetchedResultsController.sections?.count, 1)
        XCTAssertEqual(fetchedResultsController.fetchedObjects?.count, 1)

        let fetchedActivity = fetchedResultsController.object(at: IndexPath(row: 0, section: 0))

        XCTAssertEqual(fetchedActivity.completed, false, "Default Activity completed should be false")
        XCTAssertNil(fetchedActivity.completed_date, "Default Activity completed_date should be nil")
        XCTAssertNil(fetchedActivity.deferred_to, "Default Activity deferred_to should be nil")
        XCTAssertNil(fetchedActivity.deferred_to_response_due_date, "Default Activity deferred_to_response_due_date should be nil")
        XCTAssertEqual(fetchedActivity.display_order, 0, "Default Activity display_order should be 0")
        XCTAssertNil(fetchedActivity.due_date, "Default Activity due_date should be nil")
        XCTAssertEqual(fetchedActivity.estimated_timeboxes, 0, "Default Activity estimated_timeboxes should be 0")
        XCTAssertEqual(fetchedActivity.kind, .flexible, "Default Activity typeValue should be .flexible")
        XCTAssertNil(fetchedActivity.project, "Default Activity project should be nil")
        XCTAssertNil(fetchedActivity.scheduled_start, "Default Activity scheduled_start should be nil")
        XCTAssertNil(fetchedActivity.scheduled_end, "Default Activity scheduled_end should be nil")
        XCTAssertEqual(fetchedActivity.task, task, "Default Activity task should be \"\(task)\"")
        XCTAssertNil(fetchedActivity.task_info, "Default Activity task_info should be nil")
        XCTAssertEqual(fetchedActivity.today, false, "Default Activity today should be false")
        XCTAssertEqual(fetchedActivity.today_display_order, 0, "Default Activity today_display_order should be 0")
        
        XCTAssertNil(fetchedActivity.project, "Default Activity projects should be nil")
        XCTAssertEqual(fetchedActivity.timeboxes, [], "Default Activity timeboxes should be []")
        XCTAssertEqual(fetchedActivity.actual_timeboxes, 0, "Default Activity actual_timeboxes should be 0")
        
        XCTAssertEqual(fetchedActivity, activity)
    }
    
    func testManageActivity() {
        
        let fetchRequest = getActivityFetchRequest()
        let fetchedResultsController = getFetchedResultsController(fetchRequest)
        var fetchedActivityList: [Activity] {
            return fetchedResultsController.fetchedObjects!
        }

        // create an activity
        let alphaData = mockActivityList["alpha"]!
        let alpha = Activity(data: alphaData, context: managedObjectContext)
        XCTAssertTrue(alpha.objectID.isTemporaryID, "Activity should have a temporaryID")
        try! managedObjectContext.save()
        XCTAssertFalse(alpha.objectID.isTemporaryID, "Activity should not have a temporaryID")
    
        try! fetchedResultsController.performFetch()
        let fetchedActivity = fetchedActivityList.first
        
        // confirm only one activity
        XCTAssertEqual(fetchedActivityList.count, 1)
        
        // confirm activity is in the results
        XCTAssertTrue(fetchedActivityList.contains(alpha))
        
        // compare activity details
        XCTAssertEqual(fetchedActivity, alpha)
        
        let task = alphaData[Activity.Keys.Task] as! String
        XCTAssertEqual(alpha.task, task, "Activity task should be \"\(task)\"")

        let estimated_timeboxes = alphaData[Activity.Keys.EstimatedTimeboxes] as? Activity.EstimatedTimeboxesType
        XCTAssertEqual(alpha.estimated_timeboxes, estimated_timeboxes, "Activity estimated_timeboxes should be \(estimated_timeboxes)")
        
        // update acitivity details
        alpha.completed = true
        XCTAssertTrue(alpha.completed, "Activity completed should be true")
        
        alpha.today = true
        XCTAssertTrue(alpha.today, "Activity today should be true")
        
        alpha.kind = .reference
        XCTAssertEqual(alpha.kind, Activity.Kind.reference, "Activity type should be .Reference")
        
        
        // create another activity
        let bravoData = mockActivityList["bravo"]!
        let bravo = Activity(data: bravoData, context: managedObjectContext)
        try! managedObjectContext.save()
        
        try! fetchedResultsController.performFetch()

        XCTAssertEqual(fetchedActivityList.count, 2)
        
        XCTAssertTrue(fetchedActivityList.contains(alpha))
        XCTAssertTrue(fetchedActivityList.contains(bravo))

        let charlieData = mockActivityList["charlie"]!
        let charlie = Activity(data: charlieData, context: managedObjectContext)

        XCTAssertTrue(charlie.objectID.isTemporaryID, "Activity Charlie should have temporary ID")
        try! fetchedResultsController.performFetch()
        XCTAssertTrue(charlie.objectID.isTemporaryID, "Activity Charlie should have temporary ID")
        
        XCTAssertTrue(fetchedActivityList.contains(alpha))
        XCTAssertTrue(fetchedActivityList.contains(bravo))
        XCTAssertTrue(fetchedActivityList.contains(charlie))

        XCTAssertFalse(bravo.isDeleted, "Activity bravo should not be in a deleted state")
        managedObjectContext.delete(bravo)
        XCTAssertTrue(bravo.isDeleted, "Activity bravo should be in a deleted state")

        try! fetchedResultsController.performFetch()
        
        XCTAssertTrue(fetchedActivityList.contains(alpha))
        XCTAssertFalse(fetchedActivityList.contains(bravo))
        XCTAssertTrue(fetchedActivityList.contains(charlie))
    }
    
    func testActivityLists() {
        let alphaData = mockActivityList["alpha"]!
        let alpha = Activity(data: alphaData, context: managedObjectContext)
        let bravoData = mockActivityList["bravo"]!
        let bravo = Activity(data: bravoData, context: managedObjectContext)
        let charlieData = mockActivityList["charlie"]!
        let charlie = Activity(data: charlieData, context: managedObjectContext)
        let deltaData = mockActivityList["delta"]!
        let delta = Activity(data: deltaData, context: managedObjectContext)
        let echoData = mockActivityList["echo"]!
        let echo = Activity(data: echoData, context: managedObjectContext)
        
        // test activity list
        
        let activityListFetchRequest = getActivityFetchRequest()
        activityListFetchRequest.predicate = NSPredicate(format: "(completed != YES) AND (kind != \(Activity.Kind.reference.rawValue))")
        activityListFetchRequest.sortDescriptors = [NSSortDescriptor(key: Activity.Keys.DisplayOrder, ascending: true)]

        let fetchedResultsController = getFetchedResultsController(activityListFetchRequest)
        try! fetchedResultsController.performFetch()
        
        let activityList = fetchedResultsController.fetchedObjects!
        XCTAssertTrue(activityList.contains(alpha))
        XCTAssertFalse(activityList.contains(bravo))
        XCTAssertTrue(activityList.contains(charlie))
        XCTAssertFalse(activityList.contains(delta))
        XCTAssertTrue(activityList.contains(echo))
        
        // test today's activity list
        
        let todayListFetchRequest = getActivityFetchRequest()
        todayListFetchRequest.predicate = NSPredicate(format: "(today == YES) AND (completed != YES) AND (kind != \(Activity.Kind.reference.rawValue))")
        todayListFetchRequest.sortDescriptors = [NSSortDescriptor(key: Activity.Keys.TodayDisplayOrder, ascending: true)]
        
        let todayFetchedResultsController = getFetchedResultsController(todayListFetchRequest)
        try! todayFetchedResultsController.performFetch()
        
        let todayList = todayFetchedResultsController.fetchedObjects!
        XCTAssertFalse(todayList.contains(alpha))
        XCTAssertFalse(todayList.contains(bravo))
        XCTAssertFalse(todayList.contains(charlie))
        XCTAssertFalse(todayList.contains(delta))
        XCTAssertTrue(todayList.contains(echo))
        
        // test completed activity list
        
        let completedListFetchRequest = getActivityFetchRequest()
        completedListFetchRequest.predicate = NSPredicate(format: "(completed == YES) AND (kind != \(Activity.Kind.reference.rawValue))")
        completedListFetchRequest.sortDescriptors = [NSSortDescriptor(key: Activity.Keys.CompletedDate, ascending: true)]
        
        let completedFetchedResultsController = getFetchedResultsController(completedListFetchRequest)
        try! completedFetchedResultsController.performFetch()
        
        let completedList = completedFetchedResultsController.fetchedObjects!
        XCTAssertFalse(completedList.contains(alpha))
        XCTAssertTrue(completedList.contains(bravo))
        XCTAssertFalse(completedList.contains(charlie))
        XCTAssertTrue(completedList.contains(delta))
        XCTAssertFalse(completedList.contains(echo))
    }
}

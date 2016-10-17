//
//  ProjectTests.swift
//  So Much So Little
//
//  Created by Adland Lee on 10/6/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import XCTest
import CoreData
@testable import So_Much_So_Little

extension Project {
    convenience init(data: [String:Any], context: NSManagedObjectContext) {
        let name = data[Keys.Name] as? NameType ?? ""
        self.init(name: name, context: context)
        
        completed = data[Keys.Completed] as? CompletedType ?? false
        completed_date = data[Keys.CompletedDate] as? CompletedDateType
        display_order = data[Keys.DisplayOrder] as? DisplayOrderType ?? 0
        due_date = data[Keys.DueDate] as? DueDateType
        info = data[Keys.Info] as? InfoType
        
    }
}

class ProjectTests: XCTestCase {
    
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var persistentStore: NSPersistentStore!
    
    func getActivityFetchedResultsController(_ fetchRequest: NSFetchRequest<Activity>) -> NSFetchedResultsController<Activity> {
        let fetchedResultsController = NSFetchedResultsController<Activity>(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }
    
    func getProjectFetchedResultsController(_ fetchRequest: NSFetchRequest<Project>) -> NSFetchedResultsController<Project> {
        let fetchedResultsController = NSFetchedResultsController<Project>(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }
    
    func getActivityFetchRequest() -> NSFetchRequest<Activity> {
        let fetchRequest = NSFetchRequest<Activity>.init(entityName: "Activity")
        fetchRequest.sortDescriptors = []
        
        return fetchRequest
    }
    
    func getProjectFetchRequest() -> NSFetchRequest<Project> {
        let fetchRequest = NSFetchRequest<Project>.init(entityName: "Project")
        fetchRequest.sortDescriptors = []
        
        return fetchRequest
    }
    
    let mockActivityList: [String: [String:Any]] = [
        "alpha": [
            Activity.Keys.Name: "Activity Alpha"
        ],
        "bravo": [
            Activity.Keys.Name: "Activity Bravo"
        ],
        "charlie": [
            Activity.Keys.Name: "Activity Charlie"
        ],
        "delta": [
            Activity.Keys.Name: "Activity Delta"
        ]
    ]
    
    let mockProjectList: [String: [String:Any]] = [
        "alpha": [
            Project.Keys.Name: "AAAA Project",
            Project.Keys.Info: "AAAA Project extended tnformation"
        ],
        "bravo": [
            Project.Keys.Name: "BBBB Project",
            Project.Keys.Completed: true
        ],
        "charlie": [
            Project.Keys.Name: "CCCC Project"
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
    
    func testOneProject() {
        let name = "test project"
        let project = Project(name: name, context: managedObjectContext)
        try! managedObjectContext.save()
        
        let fetchRequest = getProjectFetchRequest()
        let fetchedResultsController = getProjectFetchedResultsController(fetchRequest)
        
        try! fetchedResultsController.performFetch()
        
        XCTAssertEqual(fetchedResultsController.sections!.count, 1)
        XCTAssertEqual(fetchedResultsController.fetchedObjects!.count, 1)
        
        let fetchedProject = fetchedResultsController.object(at: IndexPath(row: 0, section: 0))
        
        XCTAssertEqual(fetchedProject.completed, false, "Default Project completed should be false")
        XCTAssertNil(fetchedProject.completed_date, "Default Project completed_date should be nil")
        XCTAssertEqual(fetchedProject.display_order, 0, "Default Project display_order should be 0")
        XCTAssertNil(fetchedProject.due_date, "Default Project due_date should be nil")
        XCTAssertNil(fetchedProject.info, "Default Project info should be nil")
        
        XCTAssertEqual(fetchedProject, project)
    }
    
    // MARK: - Test Manage Projects
    func testManageProjects() {
        let projectFetchRequest = getProjectFetchRequest()
        let projectFetchedResultsController = getProjectFetchedResultsController(projectFetchRequest)
        
        var fetchedProjectList: [Project] {
            return projectFetchedResultsController.fetchedObjects!
        }
        
        // MARK: Create project
        let projectAlphaData = mockProjectList["alpha"]!
        let projectAlpha = Project(data: projectAlphaData, context: managedObjectContext)
        XCTAssertTrue(projectAlpha.objectID.isTemporaryID, "Project should have a temporary ID")
        try! managedObjectContext.save()
        XCTAssertFalse(projectAlpha.objectID.isTemporaryID, "Project should not have a temporary ID")
        
        try! projectFetchedResultsController.performFetch()
        let fetchedProject = fetchedProjectList.first
        
        // MARK: Confirm only one project
        XCTAssertEqual(fetchedProjectList.count, 1)
        
        // MARK: Confirm project is in the results
        XCTAssertTrue(fetchedProjectList.contains(projectAlpha))
        
        // MARK: Compare project details
        XCTAssertEqual(fetchedProject, projectAlpha)
        
        let name = projectAlphaData[Project.Keys.Name] as! Project.NameType
        XCTAssertEqual(projectAlpha.name, name, "Project name should be \"\(name)\"")
        let info = projectAlphaData[Project.Keys.Info] as? Project.InfoType
        XCTAssertEqual(projectAlpha.info, info, "Project info should be \(info)")
        
        // MARK: Create additional projects
        let projectBravoData = mockProjectList["bravo"]!
        let projectBravo = Project(data: projectBravoData, context: managedObjectContext)
        
        try! managedObjectContext.save()
        try! projectFetchedResultsController.performFetch()
        
        XCTAssertEqual(fetchedProjectList.count, 2)
        XCTAssertTrue(fetchedProjectList.contains(projectAlpha))
        XCTAssertTrue(fetchedProjectList.contains(projectBravo))
        
        let projectCharlieData = mockProjectList["charlie"]!
        let projectCharlie = Project(data: projectCharlieData, context: managedObjectContext)
        
        XCTAssertTrue(projectCharlie.objectID.isTemporaryID, "Project Charlie should have temporary ID")
        try! projectFetchedResultsController.performFetch()
        XCTAssertTrue(projectCharlie.objectID.isTemporaryID, "Project Charlie should have temporary ID")

        XCTAssertTrue(fetchedProjectList.contains(projectAlpha))
        XCTAssertTrue(fetchedProjectList.contains(projectBravo))
        XCTAssertTrue(fetchedProjectList.contains(projectCharlie))
        
        // MARK: Delete records
        XCTAssertFalse(projectBravo.isDeleted, "Project bravo should not be in a deleted state")
        managedObjectContext.delete(projectBravo)
        XCTAssertTrue(projectBravo.isDeleted, "Project bravo should be in a deleted state")
     
        try! projectFetchedResultsController.performFetch()
        
        XCTAssertTrue(fetchedProjectList.contains(projectAlpha))
        XCTAssertFalse(fetchedProjectList.contains(projectBravo))
        XCTAssertTrue(fetchedProjectList.contains(projectCharlie))
    }
    
    
    // MARK: - Test Project Lists
    func testProjectLists() {
        let projectAlpha = Project(data: mockProjectList["alpha"]!, context: managedObjectContext)
        let projectBravo = Project(data: mockProjectList["bravo"]!, context: managedObjectContext)
        let projectCharlie = Project(data: mockProjectList["charlie"]!, context: managedObjectContext)
        
        // MARK: test project list
        let projectListFetchRequest = getProjectFetchRequest()
        projectListFetchRequest.predicate = NSPredicate(format: "completed != YES")
        projectListFetchRequest.sortDescriptors = [NSSortDescriptor(key: Project.Keys.DisplayOrder, ascending: true)]
        
        let projectFetchedResultsController = getProjectFetchedResultsController(projectListFetchRequest)
        try! projectFetchedResultsController.performFetch()
        
        let projectList = projectFetchedResultsController.fetchedObjects!
        
        XCTAssertTrue(projectList.contains(projectAlpha))
        XCTAssertFalse(projectList.contains(projectBravo))
        XCTAssertTrue(projectList.contains(projectCharlie))
        
        
        // MARK: test completed project list
        let completedProjectListFetchRequest = getProjectFetchRequest()
        completedProjectListFetchRequest.predicate = NSPredicate(format: "completed == YES")
        completedProjectListFetchRequest.sortDescriptors = [NSSortDescriptor(key: Project.Keys.CompletedDate, ascending: true)]
        
        let completedProjectFetchedResultsController = getProjectFetchedResultsController(completedProjectListFetchRequest)
        try! completedProjectFetchedResultsController.performFetch()
        
        let completedProjectList = completedProjectFetchedResultsController.fetchedObjects!
        
        XCTAssertFalse(completedProjectList.contains(projectAlpha))
        XCTAssertTrue(completedProjectList.contains(projectBravo))
        XCTAssertFalse(completedProjectList.contains(projectCharlie))
    }
}

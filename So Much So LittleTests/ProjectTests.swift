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
    
    let mockActivityList: [AnyHashable: ActivityOptions] = [
        "alpha": ActivityOptions(
            name: "Activity Alpha"
        ),
        "bravo": ActivityOptions(
            name: "Activity Bravo"
        ),
        "charlie": ActivityOptions(
            name: "Activity Charlie"
        ),
        "delta": ActivityOptions(
            name: "Activity Delta"
        )
    ]
    
    let mockProjectList: [AnyHashable: ProjectOptions] = [
        "alpha": ProjectOptions(
            info: "AAAA Project extended tnformation",
            name: "AAAA Project"
        ),
        "bravo": ProjectOptions(
            completed: true,
            name: "BBBB Project"
        ),
        "charlie": ProjectOptions(
            name: "CCCC Project"
        )
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
        let project = Project(insertInto: managedObjectContext, with: ProjectOptions(name: name))
        try! managedObjectContext.save()
        
        let fetchRequest = getProjectFetchRequest()
        let fetchedResultsController = getProjectFetchedResultsController(fetchRequest)
        
        try! fetchedResultsController.performFetch()
        
        XCTAssertEqual(fetchedResultsController.sections!.count, 1)
        XCTAssertEqual(fetchedResultsController.fetchedObjects!.count, 1)
        
        let fetchedProject = fetchedResultsController.object(at: IndexPath(row: 0, section: 0))
        
        XCTAssertEqual(fetchedProject.completed, false, "Default Project completed should be false")
        XCTAssertNil(fetchedProject.completedDate, "Default Project completedDate should be nil")
        XCTAssertEqual(fetchedProject.displayOrder, 0, "Default Project displayOrder should be 0")
        XCTAssertNil(fetchedProject.dueDate, "Default Project dueDate should be nil")
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
        let projectAlpha = Project(insertInto: managedObjectContext, with: projectAlphaData)
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
        
        let name = projectAlphaData.name
        XCTAssertEqual(projectAlpha.name, name, "Project name should be \"\(name)\"")
        let info = projectAlphaData.info
        XCTAssertEqual(projectAlpha.info, info, "Project info should be \(String(describing:info))")
        
        // MARK: Create additional projects
        let projectBravoData = mockProjectList["bravo"]!
        let projectBravo = Project(insertInto: managedObjectContext, with: projectBravoData)
        
        try! managedObjectContext.save()
        try! projectFetchedResultsController.performFetch()
        
        XCTAssertEqual(fetchedProjectList.count, 2)
        XCTAssertTrue(fetchedProjectList.contains(projectAlpha))
        XCTAssertTrue(fetchedProjectList.contains(projectBravo))
        
        let projectCharlieData = mockProjectList["charlie"]!
        let projectCharlie = Project(insertInto: managedObjectContext, with: projectCharlieData)
        
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
        let projectAlpha = Project(insertInto: managedObjectContext, with: mockProjectList["alpha"]!)
        let projectBravo = Project(insertInto: managedObjectContext, with: mockProjectList["bravo"]!)
        let projectCharlie = Project(insertInto: managedObjectContext, with: mockProjectList["charlie"]!)
        
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

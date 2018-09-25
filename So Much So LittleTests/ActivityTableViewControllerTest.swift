//
//  ActivityTableViewControllerTest.swift
//  So Much So LittleTests
//
//  Created by Adland Lee on 7/23/18.
//  Copyright © 2018 Adland Lee. All rights reserved.
//

import XCTest
import CoreData

@testable import So_Much_So_Little

class ActivityTableViewControllerTest: XCTestCase {
    
    var viewController: ActivityTableViewController!
    var persistentContainer: NSPersistentContainer!
    var managedObjectContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    var activityDataSource: ActivityDataSourceMock!
    
    override func setUp() {
        super.setUp()

        let coder = NSKeyedUnarchiver(forReadingWith: Data())
        viewController = ActivityTableViewController(coder: coder)
        coder.finishDecoding()
        persistentContainer = PersistentContainerMock.createInMemoryPersistentContainer()
        
        activityDataSource = ActivityDataSourceMock(managedObjectContext: managedObjectContext)
        viewController.activityDataSource = activityDataSource
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let tableView = viewController.tableView!
        let section = 0
        let result = viewController.tableView(tableView, numberOfRowsInSection: section)
        let targetCount = activityDataSource.activityData[section].count
        XCTAssertEqual(result, targetCount, "Number of rows in section \(section) was not \(targetCount)")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

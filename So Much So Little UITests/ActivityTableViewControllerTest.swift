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
    var activityDataSource: ActivityDataSource_mock!
    
    var activityData: [[ActivityOptions]] =
        [
            [
                ActivityOptions(
                    completed: false,
                    completedDate: nil,
                    deferredTo: nil,
                    deferredToResponseDueDate: nil,
                    displayOrder: 0,
                    dueDate: nil,
                    estimatedTimeboxes: 0,
                    info: nil,
                    kind: .flexible,
                    name: "A 1",
                    scheduledEnd: nil,
                    scheduledStart: nil,
                    today: false,
                    todayDisplayOrder: 0
                ),
                ActivityOptions(
                    completed: false,
                    completedDate: nil,
                    deferredTo: nil,
                    deferredToResponseDueDate: nil,
                    displayOrder: 1,
                    dueDate: nil,
                    estimatedTimeboxes: 0,
                    info: nil,
                    kind: .flexible,
                    name: "A 2",
                    scheduledEnd: nil,
                    scheduledStart: nil,
                    today: false,
                    todayDisplayOrder: 0
                )
            ]
    ]

    override func setUp() {
        super.setUp()

//        let coder = NSKeyedUnarchiver(forReadingWith: Data())
//        viewController = ActivityTableViewController(coder: coder)
//        coder.finishDecoding()
//        
//        activityDataSource = ActivityDataSource_mock()
//        viewController.activityDataSource = activityDataSource
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSection0() {
        let section = 0
        
        for record in activityData[section] {
//            activityDataSource.store(with: record)
            activityDataSource.createActivity(with: record)
        }
        
//        activityDataSource.coreDataStack.saveMainContext()
        activityDataSource.save()

        let tableView = viewController.tableView!
        let result = viewController.tableView(tableView, numberOfRowsInSection: section)
        let targetCount = activityData[section].count
        XCTAssertEqual(result, targetCount, "Number of rows in section \(section) was not \(targetCount), [\(result)]")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

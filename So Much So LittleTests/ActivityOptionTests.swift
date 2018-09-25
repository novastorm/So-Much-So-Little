//
//  ActivityOptionTests.swift
//  So Much So LittleTests
//
//  Created by Adland Lee on 9/24/18.
//  Copyright © 2018 Adland Lee. All rights reserved.
//

import XCTest

@testable import So_Much_So_Little

class ActivityOptionTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDefaultActivityOptions() {
        
        let activityOptions = ActivityOptions()
        
        XCTAssertFalse(activityOptions.completed, "completed: should be false")
        XCTAssertNil(activityOptions.completedDate, "completedDate: should be nil")
        XCTAssertNil(activityOptions.deferredTo, "deferredTo: should be nil")
        XCTAssertNil(activityOptions.deferredToResponseDueDate, "deferredToResponseDueDate: should be nil")
        XCTAssertEqual(activityOptions.displayOrder, 0, "displayOrder: should be 0")
        XCTAssertNil(activityOptions.dueDate, "dueDate: should be nil")
        XCTAssertEqual(activityOptions.estimatedTimeboxes, 0, "estimatedTimeboxes: should be 0")
        XCTAssertNil(activityOptions.info, "info: should be nil")
        XCTAssertEqual(activityOptions.kind, .flexible, "kind: should be .flexible")
        XCTAssertEqual(activityOptions.name, Activity.defaultName, "name: should be \(Activity.defaultName)")
        XCTAssertNil(activityOptions.scheduledEnd, "scheduledEnd: should be nil")
        XCTAssertNil(activityOptions.scheduledStart, "scheduledStart: should be nil")
        XCTAssertFalse(activityOptions.today, "today: should be false")
        XCTAssertEqual(activityOptions.todayDisplayOrder, 0, "todayDisplayOrder: should be 0")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

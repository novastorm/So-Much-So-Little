//
//  ActivityTableViewControllerTest.swift
//  So Much So LittleTests
//
//  Created by Adland Lee on 7/23/18.
//  Copyright © 2018 Adland Lee. All rights reserved.
//

import XCTest

@testable import So_Much_So_Little

class ActivityTableViewControllerTest: XCTestCase {
    
    var viewController: ActivityTableViewController!
    
    override func setUp() {
        super.setUp()
//        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ActivityTableViewController.typeName) as! ActivityTableViewController

        let coder = NSKeyedUnarchiver(forReadingWith: Data())
        viewController = ActivityTableViewController(coder: coder)
        coder.finishDecoding()
        viewController.activityDataSource = ActivityDataSourceMock()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let tableView = viewController.tableView!
        let result = viewController.tableView(tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(result, 0, "Number of rows in section 0 was not 0")
        XCTAssertNotEqual(result, 1, "Number of rows in section 0 was not 1")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

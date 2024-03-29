//
//  So_Much_So_LittleUITestsLaunchTests.swift
//  So Much So LittleUITests
//
//  Created by Adland Lee on 3/2/22.
//  Copyright © 2022 Adland Lee. All rights reserved.
//

import XCTest

class So_Much_So_LittleUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

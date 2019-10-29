//
//  FrameTimeUITests.swift
//  FrameTimeUITests
//
//  Created by Ryan Cobelli on 10/28/19.
//  Copyright © 2019 rybel-llc. All rights reserved.
//

import XCTest

class FrameTimeUITests: XCTestCase {

    override func setUp() {
        super.setUp()
			  
	  let app = XCUIApplication()
	  app.launchArguments += [ "testing" ]
	  setupSnapshot(app)
	  app.launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}

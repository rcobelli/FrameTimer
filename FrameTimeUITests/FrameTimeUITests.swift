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
		snapshot("01-home")
		
		let goButton = XCUIApplication().buttons["Go!"]
		goButton.tap()
		snapshot("00-analysis")		
    }
}

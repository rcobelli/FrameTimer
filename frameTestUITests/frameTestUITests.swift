//
//  frameTestUITests.swift
//  frameTestUITests
//
//  Created by Ryan Cobelli on 11/8/15.
//  Copyright © 2015 Rybel. All rights reserved.
//

import XCTest

class frameTestUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
		
		let app = XCUIApplication()
		setupSnapshot(app)
		continueAfterFailure = false
		app.launchArguments = [ "testing" ]
		app.launch()
	}
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
		let app = XCUIApplication()
		sleep(1)
		snapshot("0-mainScreen")
		
		app.buttons.elementBoundByIndex(0).tap()
		sleep(1)
		snapshot("1-settings")
    }
    
}

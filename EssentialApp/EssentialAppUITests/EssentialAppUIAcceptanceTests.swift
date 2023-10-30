//
//  EssentialAppUITests.swift
//  EssentialAppUITests
//
//  Created by Jacob Rakidzich on 10/24/23.
//

import XCTest

final class EssentialAppUIAcceptanceTests: XCTestCase {
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        
        app.launch()
        
        XCTAssertEqual(app.cells.count, 22)
        XCTAssertTrue(app.cells.images.count > 0)
    }
}

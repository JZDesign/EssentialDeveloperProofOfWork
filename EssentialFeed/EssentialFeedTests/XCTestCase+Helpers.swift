//
//  XCTestCase+Helpers.swift
//  EssentialFeedTests
//
//  Created by Jacob Rakidzich on 10/13/23.
//

import Foundation
import XCTest

extension XCTestCase {
    func createAndTrackMemoryLeaks<T: AnyObject>(
        _ initializer: @autoclosure () -> T,
        file: StaticString = #file,
        line: UInt = #line
    ) -> T {
        let instance = initializer()
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance \(String(describing: instance)) should have been deallocated.", file: file, line: line)
        }
        return instance
    }
}

func anyURL() -> URL {
    URL(string: "https://test.com")!
}

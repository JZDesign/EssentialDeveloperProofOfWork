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

func anyData() -> Data {
    "oh hey".data(using: .utf8)!
}

func anyNSError() -> NSError {
    NSError(domain: "1", code: 1)
}

func anyHttpResponse() -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
}

func nonHttpResponse() -> URLResponse {
    URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
}


//
//  XCTestCase+Helpers.swift
//  EssentialFeedTests
//
//  Created by Jacob Rakidzich on 10/13/23.
//

import EssentialFeed
import Foundation
import XCTest

public extension XCTestCase {
    func createAndTrackMemoryLeaks<T: AnyObject>(
        _ initializer: @autoclosure () -> T,
        file: StaticString = #file,
        line: UInt = #line
    ) -> T {
        let instance = initializer()
        trackForMemoryLeaks(instance, file: file, line: line)
        return instance
    }
    
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}

public func uniqueImage() -> FeedImage {
    FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}


public func uniqueImages() -> (model: [FeedImage], local: [LocalFeedImage]) {
    let remote = [
        uniqueImage(),
        uniqueImage(),
        uniqueImage(),
        uniqueImage(),
        uniqueImage(),
        uniqueImage(),
    ]
    return (remote, remote.map(\.asLocal))
}

public func anyURL() -> URL {
    URL(string: "https://test.com")!
}

public func anyData() -> Data {
    "oh hey".data(using: .utf8)!
}

public func anyNSError() -> NSError {
    NSError(domain: "1", code: 1)
}

public func anyHttpResponse() -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
}

public func nonHttpResponse() -> URLResponse {
    URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
}

public struct EquatableError: Error, Equatable {
    public let id: UUID
    
    public init(id: UUID = .init()) {
        self.id = id
    }
}

public extension Date {
    func minusFeedCacheMaxAge() -> Date {
        adding(days: -7)!
    }
}

public func makeItemsJSON(_ items: [[String: Any]]) -> Data {
    let json = ["items": items]
    return try! JSONSerialization.data(withJSONObject: json)
}

public extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

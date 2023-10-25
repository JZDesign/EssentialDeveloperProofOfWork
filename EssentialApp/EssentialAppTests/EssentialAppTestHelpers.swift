//
//  EssentialAppTests.swift
//  EssentialAppTests
//
//  Created by Jacob Rakidzich on 10/24/23.
//


import EssentialFeediOS
import EssentialFeed
import Foundation
import XCTest

@testable import EssentialApp

extension XCTestCase {
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

func uniqueImage() -> FeedImage {
    FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}


func uniqueImages() -> (model: [FeedImage], local: [LocalFeedImage]) {
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

struct EquatableError: Error, Equatable {
    let id: UUID
    
    init(id: UUID = .init()) {
        self.id = id
    }
}

extension Date {
    func minusFeedCacheMaxAge() -> Date {
        adding(days: -7)!
    }
}

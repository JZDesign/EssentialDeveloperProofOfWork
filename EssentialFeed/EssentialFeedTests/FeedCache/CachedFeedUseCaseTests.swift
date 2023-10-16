//
//  CachedFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Jacob Rakidzich on 10/16/23.
//

import XCTest

final class CachedFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let feedStore = makeSUT()
        XCTAssertEqual(feedStore.deleteCacheCallCount, 0)
    }
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
        createAndTrackMemoryLeaks(FeedStore(), file: file, line: line)
    }
}

class FeedStore {
    var deleteCacheCallCount = 0
}

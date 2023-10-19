//
//  ValidateCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Jacob Rakidzich on 10/17/23.
//

import XCTest
import EssentialFeed

final class ValidateCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetievalError() {
        let (sut, store) = makeSUT()
        sut.validateCache()
        store.completeRetrieval(with: .init())
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()
        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteLessThanSevenDaysOldCache() {
        let feed = uniqueImages()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate
            .adding(days: -7)!
            .adding(seconds: 1)!
        
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrievalSuccessfully(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_validateCache_deletesSevenDaysOldCache() {
        let feed = uniqueImages()
        let fixedCurrentDate = Date()
        let sevenDaysOldTimestamp = fixedCurrentDate
            .adding(days: -7)!
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.validateCache()
        store.completeRetrievalSuccessfully(with: feed.local, timestamp: sevenDaysOldTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }

    func test_validateCache_deletesMoreThanSevenDaysOldCache() {
        let feed = uniqueImages()
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimestamp = fixedCurrentDate
            .adding(days: -7)!
            .adding(seconds: -1)!
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.validateCache()
        store.completeRetrievalSuccessfully(with: feed.local, timestamp: moreThanSevenDaysOldTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    
    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        var (sut, store): (LocalFeedLoader?, FeedStoreSpy) = makeSUT()

        sut?.validateCache()

        sut = nil
        store.completeRetrieval(with: .init())

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    // MARK: Helpers
    
    func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = createAndTrackMemoryLeaks(FeedStoreSpy(), file: file, line: line)
        let loader = createAndTrackMemoryLeaks(LocalFeedLoader(store:  store, currentDate: currentDate), file: file, line: line)
        return (loader, store)
    }
}

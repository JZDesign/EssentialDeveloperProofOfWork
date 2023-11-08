//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Jacob Rakidzich on 10/17/23.
//

import XCTest
import EssentialFeed
import EssentialFeedTestHelpers

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        _ = try? sut.load()
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let expectedError = EquatableError()

        expect(sut, toCompleteWith: .failure(expectedError), when: {
            store.completeRetrieval(with: expectedError)
        })
    }

    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWith: .success([]), when: {            
            store.completeRetrievalWithEmptyCache()
        })
    }
    
    func test_load_deliversCachedImagesWhenFeedIsLessThanSevenDaysOld() {
        let fixedCurrentDate = Date.now
        let lessThanSevenDays = Date.now
            .minusFeedCacheMaxAge()
            .adding(seconds: 1)!
        
        let feed = uniqueImages()
        let (sut, store) = makeSUT { fixedCurrentDate }
        expect(sut, toCompleteWith: .success(feed.model), when: {
            store.completeRetrievalSuccessfully(with: feed.local, timestamp: lessThanSevenDays)
        })
    }
    
    func test_load_doesNotDeliverCachedImagesWhenFeedIsExactlySevenDaysOld() {
        let fixedCurrentDate = Date.now
        let sevenDaysOld = Date.now
            .minusFeedCacheMaxAge()
        
        let feed = uniqueImages()
        let (sut, store) = makeSUT { fixedCurrentDate }
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrievalSuccessfully(with: feed.local, timestamp: sevenDaysOld)
        })
    }
    
    func test_load_doesNotDeliverCachedImagesWhenFeedIsMoreThanSevenDaysOld() {
        let fixedCurrentDate = Date.now
        let sevenDaysOld = Date.now
            .minusFeedCacheMaxAge()
            .adding(seconds: -1)!
        
        let feed = uniqueImages()
        let (sut, store) = makeSUT { fixedCurrentDate }
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrievalSuccessfully(with: feed.local, timestamp: sevenDaysOld)
        })
    }
    
    func test_load_hasNoSideEffectsOnRetievalError() {
        let (sut, store) = makeSUT()
        _ = try? sut.load()
        store.completeRetrieval(with: .init())
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()
        _ = try? sut.load()
        store.completeRetrievalWithEmptyCache()
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnLessThanSevenDaysOldCache() {
        let feed = uniqueImages()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate
            .minusFeedCacheMaxAge()
            .adding(seconds: 1)!
        
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        _ = try? sut.load()
        store.completeRetrievalSuccessfully(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    // MARK: Helpers
    
    func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = createAndTrackMemoryLeaks(FeedStoreSpy(), file: file, line: line)
        let loader = createAndTrackMemoryLeaks(LocalFeedLoader(store:  store, currentDate: currentDate), file: file, line: line)
        return (loader, store)
    }
    
    private func expect(
        _ sut: LocalFeedLoader,
        toCompleteWith expectedResult: Result<[FeedImage], Error>,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        action()

        let receivedResult = Result { try sut.load() }
        
        switch (receivedResult, expectedResult) {
        case let (.success(receivedImages), .success(expectedImages)):
            XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
            
        case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            
        default:
            XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
        }
    }
}

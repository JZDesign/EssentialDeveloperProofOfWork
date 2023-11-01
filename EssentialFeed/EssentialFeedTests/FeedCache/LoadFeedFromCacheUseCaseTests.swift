//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Jacob Rakidzich on 10/17/23.
//

import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        sut.load { _ in }
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
        expect(sut, toCompleteWith: .success([]), when: {            store.completeRetrievalWithEmptyCache()
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
    
    func test_load_doesNotDeliverResultAfterSUTHasBeenDeallocated() {
        var (sut, store): (LocalFeedLoader?, FeedStoreSpy) = makeSUT()
        sut?.load { _ in
            XCTFail(#function)
        }
        sut = nil
        store.completeRetrievalSuccessfully(with: [])
    }
    
    func test_load_hasNoSideEffectsOnRetievalError() {
        let (sut, store) = makeSUT()
        sut.load { _ in }
        store.completeRetrieval(with: .init())
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()
        sut.load { _ in }
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
        sut.load { _ in }
        store.completeRetrievalSuccessfully(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    // MARK: Helpers
    
    func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = createAndTrackMemoryLeaks(FeedStoreSpy(), file: file, line: line)
        let loader = createAndTrackMemoryLeaks(LocalFeedLoader(store:  store, currentDate: currentDate), file: file, line: line)
        return (loader, store)
    }
    
    func expect(
        _ sut: LocalFeedLoader,
        toCompleteWith expectedResult: LocalFeedLoader.LoadResult,
        file: StaticString = #file,
        line: UInt = #line,
        when action: () -> Void
    ) {
        
        let expectation = expectation(description: #function)
        
        sut.load { recievedResult in
            switch (recievedResult, expectedResult) {
            case let (.success(values), .success(expectedValues)):
                XCTAssertEqual(values, expectedValues, file: file, line: line)
            case let (.failure(error), .failure(expectedError)):
                XCTAssertEqual(
                    (error as? EquatableError)!,
                    (expectedError as? EquatableError)!,
                    file: file,
                    line: line
                )
            default:
                XCTFail("Expected \(expectedResult) got \(recievedResult) instead")
            }
            expectation.fulfill()
        }
        
        action()
        wait(for: [expectation], timeout: 2)
    }
}

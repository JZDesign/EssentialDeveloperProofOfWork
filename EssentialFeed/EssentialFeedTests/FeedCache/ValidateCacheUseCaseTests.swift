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
        XCTAssertEqual(store.recievedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetievalError() {
        let (sut, store) = makeSUT()
        sut.validateCache()
        store.completeRetrieval(with: .init())
        XCTAssertEqual(store.recievedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()
        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    // MARK: Helpers
    
    func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = createAndTrackMemoryLeaks(FeedStoreSpy(), file: file, line: line)
        let loader = createAndTrackMemoryLeaks(LocalFeedLoader(store:  store, currentDate: currentDate), file: file, line: line)
        return (loader, store)
    }
    
    func expect(
        _ sut: LocalFeedLoader,
        toCompleteWith expectedResult: LoadFeedResult,
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
        wait(for: [expectation])
    }
}

//
//  CachedFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Jacob Rakidzich on 10/16/23.
//

import XCTest
import EssentialFeed

final class CachedFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        store.completeDeletion(with: .init())
        sut.save(uniqueImages().model) { _ in }
                
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
        
    func test_save_requestCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let images = uniqueImages()
        let timestamp = Date.now
        let (sut, store) = makeSUT(currentDate: { timestamp })
        store.completeDeletionSuccessfully()
        sut.save(images.model) { _ in }
                
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(images.local, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let expectedError = EquatableError()
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWithError: expectedError) {
            store.completeDeletion(with: expectedError)
        }
    }
    
    func test_save_failsOnInsertionError() {
        let expectedError = EquatableError()
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWithError: expectedError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: expectedError)
        }
    }
    
    func test_save_succeedsOnSuccessfulInsertion() {
        let (sut, store) = makeSUT()
        expectSuccess(sut) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }

    // MARK: Helpers
    
    func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = createAndTrackMemoryLeaks(FeedStoreSpy(), file: file, line: line)
        let loader = createAndTrackMemoryLeaks(LocalFeedLoader(store:  store, currentDate: currentDate), file: file, line: line)
        return (loader, store)
    }
    
    func expectSuccess(_ sut: LocalFeedLoader, file: StaticString = #file, line: UInt = #line, when action: () -> Void) {
        expect(sut, toCompleteWithError: nil, file: file, line: line, when: action)
    }
    
    func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: EquatableError?, file: StaticString = #file, line: UInt = #line, when action: () -> Void) {
        var recievedError: Error?
        
        let expectation = expectation(description: #function)
        action()
        
        sut.save([]) { _result in
            if case let Result.failure(error) = _result { recievedError = error }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(expectedError, recievedError as? EquatableError, file: file, line: line)
    }
}

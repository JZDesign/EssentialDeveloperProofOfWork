//
//  CachedFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Jacob Rakidzich on 10/16/23.
//

import XCTest
import EssentialFeed
import EssentialFeedTestHelpers

final class CachedFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        store.completeDeletion(with: .init())
        try? sut.save(uniqueImages().model)
                
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
        
    func test_save_requestCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let images = uniqueImages()
        let timestamp = Date.now
        let (sut, store) = makeSUT(currentDate: { timestamp })
        store.completeDeletionSuccessfully()
        try? sut.save(images.model)
                
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
        do {
            try sut.save(uniqueImages().model)
        } catch {
            XCTAssertEqual(error as? EquatableError, expectedError, file: file, line: line)
        }
    }
}

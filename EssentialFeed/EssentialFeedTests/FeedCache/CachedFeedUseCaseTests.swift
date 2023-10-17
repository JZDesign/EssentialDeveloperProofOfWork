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
        XCTAssertEqual(store.recievedMessages, [])
    }

    func test_save_deletesCache() {
        let (sut, store) = makeSUT()
        sut.save(uniqueItems().remote)
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        sut.save(uniqueItems().remote)
        store.completeDeletion(with: .init())
                
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }
        
    func test_save_requestCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let items = uniqueItems()
        let timestamp = Date.now
        let (sut, store) = makeSUT(currentDate: { timestamp })
        sut.save(items.remote)
        store.completeDeletionSuccessfully()
                
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed, .insert(items.local, timestamp)])
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
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTHasBeenDeallocated() {
        var (sut, store): (LocalFeedLoader?, FeedStoreSpy) = makeSUT()
        var result = [Error?]()
        sut?.save([]) { result.append($0) }
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: .init())
        XCTAssertEqual(result.count, 0)
    }
    
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTHasBeenDeallocated() {
        var (sut, store): (LocalFeedLoader?, FeedStoreSpy) = makeSUT()
        var result = [Error?]()
        sut?.save([]) { result.append($0) }
        sut = nil
        store.completeDeletion(with: .init())
        XCTAssertEqual(result.count, 0)
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
        
        sut.save([]) {
            recievedError = $0
            expectation.fulfill()
        }
        
        action()
        wait(for: [expectation])
        
        XCTAssertEqual(expectedError, recievedError as? EquatableError, file: file, line: line)
    }
}

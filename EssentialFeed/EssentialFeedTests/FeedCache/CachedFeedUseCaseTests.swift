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
        sut.save([uniqueItem()])
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let items = [uniqueItem(), uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        sut.save(items)
        store.completeDeletion(with: .init())
                
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }
        
    func test_save_requestCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let items = [uniqueItem(), uniqueItem(), uniqueItem()]
        let timestamp = Date.now
        let (sut, store) = makeSUT(currentDate: { timestamp })
        sut.save(items)
        store.completeDeletionSuccessfully()
                
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed, .insert(items, timestamp)])
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


public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insertItems(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}

public class LocalFeedLoader {
    let store: FeedStore
    let currentDate: () -> Date
    public typealias SaveResult = (Error?) -> Void
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    public func save(_ items: [FeedItem], completion: @escaping SaveResult = { _ in }) {
        store.deleteCachedFeed { [weak self] error in
            guard let self else { return }
            if let error {
                completion(error)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    private func cache(_ items: [FeedItem], with completion: @escaping SaveResult) {
        store.insertItems(items, timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

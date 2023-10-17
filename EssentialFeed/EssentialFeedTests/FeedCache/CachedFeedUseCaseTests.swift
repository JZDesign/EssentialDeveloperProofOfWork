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
        store.completeDeletion(with: anyNSError())
                
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
        var recievedError: Error?
        
        let expectation = expectation(description: #function)
        
        sut.save([]) {
            recievedError = $0
            expectation.fulfill()
        }
        
        store.completeDeletion(with: expectedError)

        wait(for: [expectation])
        
        XCTAssertEqual(expectedError, recievedError as! EquatableError)
    }
    
    
    func test_save_failsOnInsertionError() {
        let expectedError = EquatableError()
        let (sut, store) = makeSUT()
        var recievedError: Error?
        
        let expectation = expectation(description: #function)
        
        sut.save([]) {
            recievedError = $0
            expectation.fulfill()
        }
        
        store.completeDeletionSuccessfully()
        store.completeInsertion(with: expectedError)
        wait(for: [expectation])
        
        XCTAssertEqual(expectedError, recievedError as! EquatableError)
    }
    // MARK: Helpers
    
    func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = createAndTrackMemoryLeaks(FeedStore(), file: file, line: line)
        let loader = createAndTrackMemoryLeaks(LocalFeedLoader(store:  store, currentDate: currentDate), file: file, line: line)
        return (loader, store)
    }
}


class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    var deletionCompletions = [DeletionCompletion]()
    
    typealias InsertionCompletion = (Error?) -> Void
    var insertionCompletions = [InsertionCompletion]()
    
    private(set) var recievedMessages = [ReceivedMessage]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        recievedMessages.append(.deleteCachedFeed)
    }
    
    func insertItems(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        recievedMessages.append(.insert(items, timestamp))
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([FeedItem], Date)
    }
    
}

class LocalFeedLoader {
    let store: FeedStore
    let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void = { _ in }) {
        store.deleteCachedFeed { [weak self] error in
            guard error == nil, let self else {
                completion(error)
                return
            }
            self.store.insertItems(items, timestamp: self.currentDate()) { error in
                guard error == nil else {
                    completion(error)
                    return
                }
            }
        }
    }
}

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
        XCTAssertEqual(store.deleteCacheCallCount, 0)
    }

    func test_save_deletesCache() {
        let (sut, store) = makeSUT()
        sut.save([uniqueItem()])
        XCTAssertEqual(store.deleteCacheCallCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let items = [uniqueItem(), uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        sut.save(items)
        store.completeDeletion(with: anyNSError())
                
        XCTAssertEqual(store.insertCacheCallCount, 0)
    }
        
    func test_save_requestCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let items = [uniqueItem(), uniqueItem(), uniqueItem()]
        let timestamp = Date.now
        let (sut, store) = makeSUT(currentDate: { timestamp })
        sut.save(items)
        store.completeDeletionSuccessfully()
                
        XCTAssertEqual(store.insertCacheCallCount, 1)
        XCTAssertEqual(store.insertions.first!.items, items)
        XCTAssertEqual(store.insertions.first!.timestamp, timestamp)
    }
    
    // MARK: Helpers
    
    func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = createAndTrackMemoryLeaks(FeedStore(), file: file, line: line)
        let loader = createAndTrackMemoryLeaks(LocalFeedLoader(store:  store, currentDate: currentDate), file: file, line: line)
        return (loader, store)
    }
}


typealias DeletionCompletion = (Error?) -> Void
class FeedStore {
    var deletionCompletions = [DeletionCompletion]()
    var deleteCacheCallCount: Int {
        deletionCompletions.count
    }
    
    var insertions = [(items: [FeedItem], timestamp: Date)]()
    var insertCacheCallCount: Int {
        insertions.count
    }
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
    }
    
    func insertItems(_ items: [FeedItem], timestamp: Date) {
        insertions.append((items, timestamp))
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
}

class LocalFeedLoader {
    let store: FeedStore
    let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed { [weak self] error in
            guard error == nil, let self else {
                return
            }
            self.store.insertItems(items, timestamp: self.currentDate())
        }
    }
}

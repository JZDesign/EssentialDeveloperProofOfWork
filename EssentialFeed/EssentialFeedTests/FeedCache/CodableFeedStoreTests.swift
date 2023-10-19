//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Jacob Rakidzich on 10/19/23.
//

import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        expect(makeSUT(), toRetrieveTwice: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        expect(makeSUT(), toRetrieve: .empty)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImages().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)

        expect(sut, toRetrieveTwice: .found(images: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImages().local
        let timestamp = Date()

        insert((feed, timestamp), to: sut)

        expect(sut, toRetrieve: .found(images: feed, timestamp: timestamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(EquatableError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        let firstInsertionError = insert((uniqueImages().local, Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
        
        let latestFeed = uniqueImages().local
        let latestTimestamp = Date()
        let latestInsertionError = insert((latestFeed, latestTimestamp), to: sut)
        
        XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
        expect(sut, toRetrieve: .found(images: latestFeed, timestamp: latestTimestamp))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImages().local
        let timestamp = Date()

        let insertionError = insert((feed, timestamp), to: sut)

        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
        expect(sut, toRetrieve: .empty)
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        XCTAssertNil(deleteCache(from: sut), "Expected empty cache deletion to succeed")
        expect(sut, toRetrieve: .empty)
    }
    
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
    
        insert((uniqueImages().local, Date()), to: sut)

        XCTAssertNil(deleteCache(from: sut), "Expected non-empty cache deletion to succeed")
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)

        XCTAssertNotNil(deleteCache(from: sut), "Expected cache deletion to fail")
        expect(sut, toRetrieve: .empty)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        var completedOperationsInOrder = [XCTestExpectation]()
        
        let operation = expectation(description: "Operation 1")
        sut.insert(uniqueImages().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(operation)
            operation.fulfill()
        }
        
        let operation2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            completedOperationsInOrder.append(operation2)
            operation2.fulfill()
        }
        
        let operation3 = expectation(description: "Operation 3")
        sut.insert(uniqueImages().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(operation3)
            operation3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(completedOperationsInOrder, [operation, operation2, operation3], "Expected to run serially but finished in the wrong order")
    }
    
    // Helpers
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func testSpecificStoreURL() -> URL {
        cachesDirectory().appendingPathComponent("image-feed.store")
    }
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        return createAndTrackMemoryLeaks(CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL()), file: file, line: line)
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func expect(
        _ sut: FeedStore,
        toRetrieve expectedResult: LocalFeedResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
                
            case let (.found(expectedFeed, expectedTimestamp), .found(retrievedFeed, retrievedTimestamp)):
                XCTAssertEqual(retrievedFeed, expectedFeed, file: file, line: line)
                XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(
        _ sut: FeedStore,
        toRetrieveTwice expectedResult: LocalFeedResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }

    @discardableResult
    private func insert(
        _ cache: (feed: [LocalFeedImage], timestamp: Date), 
        to sut: FeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var error: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { insertionError in
            error = insertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return error
    }
    
    private func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        sut.deleteCachedFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
}

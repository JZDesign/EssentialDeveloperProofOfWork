//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Jacob Rakidzich on 10/19/23.
//

import XCTest
import EssentialFeed

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {

    func test_retrieve_deliversEmptyOnEmptyCache() {
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: makeSUT())
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() { 
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: makeSUT())
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: makeSUT())
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() { 
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: makeSUT())
    }

    func test_insert_deliversNoErrorOnEmptyCache() {
        assertThatInsertDeliversNoErrorOnEmptyCache(on: makeSUT())
    }

    func test_insert_deliversNoErrorOnNonEmptyCache() { 
        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: makeSUT())
    }

    func test_insert_overridesPreviouslyInsertedCacheValues() { 
        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: makeSUT())
    }

    func test_delete_deliversNoErrorOnEmptyCache() { 
        assertThatDeleteDeliversNoErrorOnEmptyCache(on: makeSUT())
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: makeSUT())
    }

    func test_delete_deliversNoErrorOnNonEmptyCache() { 
        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: makeSUT())
    }

    func test_delete_emptiesPreviouslyInsertedCache() { }

    func test_storeSideEffects_runSerially() { }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        return createAndTrackMemoryLeaks(try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle))
    }
}

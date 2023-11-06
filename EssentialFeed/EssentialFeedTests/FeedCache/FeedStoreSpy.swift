//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Jacob Rakidzich on 10/17/23.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    private var deletionResult: Result<Void, Error>?
    private var insertionResult: Result<Void, Error>?
    private var retrievalResult: Result<CachedFeed?, Error>?
    private(set) var receivedMessages = [ReceivedMessage]()
    
    func deleteCachedFeed() throws {
        receivedMessages.append(.deleteCachedFeed)
        try deletionResult?.get()
    }
    
    func completeDeletion(with error: EquatableError) {
        deletionResult = .failure(error)
    }
    
    func completeDeletionSuccessfully() {
        deletionResult = .success(())
    }
    
    func insert(_ images: [LocalFeedImage], timestamp: Date) throws {
        receivedMessages.append(.insert(images, timestamp))
        try insertionResult?.get()
    }
    
    func completeInsertion(with error: EquatableError) {
        insertionResult = .failure(error)
    }
    
    func completeInsertionSuccessfully() {
        insertionResult = .success(())
    }
    
    func retrieve() throws -> CachedFeed? {
        receivedMessages.append(.retrieve)
        return try retrievalResult?.get()
    }
    
    func completeRetrieval(with error: EquatableError) {
        retrievalResult = .failure(error)
    }
    
    func completeRetrievalWithEmptyCache() {
        retrievalResult = .success(.none)
    }
    
    func completeRetrieval(with images: [LocalFeedImage], timestamp: Date) {
        retrievalResult = .success(CachedFeed(images: images, timestamp: timestamp))
    }
    
    func completeRetrievalSuccessfully(with images: [LocalFeedImage], timestamp: Date = .now) {
        completeRetrieval(with: images, timestamp: timestamp)
    }
    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
}

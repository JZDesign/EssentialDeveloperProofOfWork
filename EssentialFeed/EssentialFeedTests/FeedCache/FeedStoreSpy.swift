//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Jacob Rakidzich on 10/17/23.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    var deletionCompletions = [FeedStore.DeletionCompletion]()
    var insertionCompletions = [FeedStore.InsertionCompletion]()
    var retrievalCompletions = [FeedStore.RetrievalCompletion]()
    private(set) var receivedMessages = [ReceivedMessage]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func insert(_ images: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(images, timestamp))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompletions[index](.success(.empty))
    }
    
    func completeRetrieval(with error: EquatableError, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrievalSuccessfully(with images: [LocalFeedImage], timestamp: Date = .now, at index: Int = 0) {
        retrievalCompletions[index](.success(.found(images: images, timestamp: timestamp)))
    }
    
    func completeDeletion(with error: EquatableError, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeInsertion(with error: EquatableError, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
}

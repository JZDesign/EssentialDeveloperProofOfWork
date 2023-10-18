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
    var retrievalCompletions = [(LoadFeedResult) -> Void]()
    private(set) var recievedMessages = [ReceivedMessage]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        recievedMessages.append(.deleteCachedFeed)
    }
    
    func insertImages(_ images: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        recievedMessages.append(.insert(images, timestamp))
    }
    
    func retieve(completion: @escaping (LoadFeedResult) -> Void) {
        retrievalCompletions.append(completion)
        recievedMessages.append(.retrieve)
    }
    
    func completeRetrieval(with error: EquatableError, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrievalSuccessfully(with images: [FeedImage], at index: Int = 0) {
        retrievalCompletions[index](.success(images))
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

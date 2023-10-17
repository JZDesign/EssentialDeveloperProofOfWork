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
    
    private(set) var recievedMessages = [ReceivedMessage]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        recievedMessages.append(.deleteCachedFeed)
    }
    
    func insertItems(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        recievedMessages.append(.insert(items, timestamp))
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
        case insert([FeedItem], Date)
    }
}

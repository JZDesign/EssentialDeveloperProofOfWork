//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/17/23.
//

import Foundation

public protocol FeedStore {
    typealias RetrievalResult = Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void
    
    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    func retrieve(completion: @escaping RetrievalCompletion)
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ images: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
}

public struct CachedFeed: Equatable {
    let images: [LocalFeedImage]
    let timestamp: Date

    public init(images: [LocalFeedImage], timestamp: Date) {
        self.images = images
        self.timestamp = timestamp
    }
}

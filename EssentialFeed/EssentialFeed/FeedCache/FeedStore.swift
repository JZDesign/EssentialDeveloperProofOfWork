//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/17/23.
//

import Foundation

public protocol FeedStore {
    typealias RetrievalResult = Result<CachedFeed, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func retrieve(completion: @escaping RetrievalCompletion)
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ images: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
}

public enum CachedFeed {
    case empty
    case failure(Error)
    case found(images: [LocalFeedImage], timestamp: Date)
}

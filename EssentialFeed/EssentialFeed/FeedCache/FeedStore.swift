//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/17/23.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrieveCompletion = (CachedFeed) -> Void
    
    func retrieve(completion: @escaping RetrieveCompletion)
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ images: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
}

public enum CachedFeed {
    case empty
    case failure(Error)
    case found(images: [LocalFeedImage], timestamp: Date)
}

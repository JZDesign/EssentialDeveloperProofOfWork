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
    typealias RetrieveCompletion = (LoadFeedResult) -> Void
    
    func retieve(completion: @escaping RetrieveCompletion)
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insertImages(_ images: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
}

//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/19/23.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
    public init() {}

    public func retrieve(completion: @escaping RetrieveCompletion) {
        completion(.empty)
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) { }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) { }

}

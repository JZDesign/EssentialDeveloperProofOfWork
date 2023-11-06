//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/17/23.
//

import Foundation

public class LocalFeedLoader: FeedCache  {
    public typealias ValidationResult = Result<Void, Error>

    let store: FeedStore
    let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func load() throws -> [FeedImage] {
        if let cache = try store.retrieve(), FeedCachePolicy.validate(cache.timestamp, againstDate: currentDate()) {
            return cache.images.map { $0.asModel }
        }
        return []
    }
    
    public func save(_ feed: [FeedImage]) throws {
        try store.deleteCachedFeed()
        try store.insert(feed.map(\.asLocal), timestamp: currentDate())
    }

    private struct InvalidCache: Error {}
    
    public func validateCache(completion: @escaping (ValidationResult) -> Void) {        
        completion(
            ValidationResult {
                do {
                    if let cache = try store.retrieve(), !FeedCachePolicy.validate(cache.timestamp, againstDate: currentDate()) {
                        throw InvalidCache()
                    }
                } catch {
                    try store.deleteCachedFeed()
                }
            }
        )
    }
    
}

public extension FeedImage {
    var asLocal: LocalFeedImage {
        .init(id: id, description: description, location: location, imageURL: url)
    }
}

public extension LocalFeedImage {
    var asModel: FeedImage {
        .init(id: id, description: description, location: location, url: imageURL)
    }
}

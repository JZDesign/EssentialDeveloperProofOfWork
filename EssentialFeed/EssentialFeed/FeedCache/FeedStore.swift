//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/17/23.
//

import Foundation

public protocol FeedStore {
    func deleteCachedFeed() throws
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws
    func retrieve() throws -> CachedFeed?
}

public struct CachedFeed: Equatable {
    public let images: [LocalFeedImage]
    public let timestamp: Date

    public init(images: [LocalFeedImage], timestamp: Date) {
        self.images = images
        self.timestamp = timestamp
    }
}

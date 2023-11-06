//
//  InMemoryFeedStoru.swift
//  EssentialAppTests
//
//  Created by Jacob Rakidzich on 11/1/23.
//

import EssentialFeed
import EssentialFeediOS

class InMemoryFeedStore: FeedStore {
    private(set) var feedCache: CachedFeed?
    private var feedImageDataCache: [URL: Data] = [:]

    private init(feedCache: CachedFeed? = nil) {
        self.feedCache = feedCache
    }
    
    func deleteCachedFeed() throws {
        feedCache = nil
    }
    
    func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date) throws {
        feedCache = CachedFeed(images: feed + (feedCache?.images ?? []), timestamp: timestamp)
    }
    
    func retrieve() throws -> EssentialFeed.CachedFeed? {
        feedCache
    }

    static var empty: InMemoryFeedStore {
        InMemoryFeedStore()
    }
    
    static var withExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CachedFeed(images: [], timestamp: Date.distantPast))
    }
    
    static var withNonExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CachedFeed(images: [], timestamp: Date()))
    }
}


extension InMemoryFeedStore: FeedImageDataStore {
    
    func insert(_ data: Data, for url: URL) throws {
        feedImageDataCache[url] = data
    }
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        feedImageDataCache[url]
    }
    
}

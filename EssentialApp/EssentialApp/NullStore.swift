//
//  NullStore.swift
//  EssentialApp
//
//  Created by Jacob Rakidzich on 11/6/23.
//

import Foundation
import EssentialFeed

class NullStore: FeedStore, FeedImageDataStore {
    func retrieve() throws -> EssentialFeed.CachedFeed? { nil }
    func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date) throws {}
    func deleteCachedFeed() throws {}
    
    func insert(_ data: Data, for url: URL) throws {}
    func retrieve(dataForURL url: URL) throws -> Data? { .none }
}

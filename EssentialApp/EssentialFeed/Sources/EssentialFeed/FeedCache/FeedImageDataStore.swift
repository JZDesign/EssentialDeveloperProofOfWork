//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/24/23.
//

import Foundation

public protocol FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
}

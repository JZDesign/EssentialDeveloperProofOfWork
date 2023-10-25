//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/25/23.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}

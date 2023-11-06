//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/25/23.
//

import Foundation

public protocol FeedCache {
    func save(_ feed: [FeedImage]) throws
}

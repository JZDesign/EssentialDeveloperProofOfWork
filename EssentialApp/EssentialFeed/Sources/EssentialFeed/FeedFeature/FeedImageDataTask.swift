//
//  FeedImageDataTask.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/25/23.
//

import Foundation

public protocol FeedImageDataCache {
    func save(_ data: Data, for url: URL) throws
}

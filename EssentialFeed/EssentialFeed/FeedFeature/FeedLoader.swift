//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/12/23.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(completion: @escaping (FeedLoader.Result) -> Void)
}

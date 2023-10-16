//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/12/23.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedItem], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}

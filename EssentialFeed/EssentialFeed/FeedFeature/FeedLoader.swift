//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/12/23.
//

import Foundation

typealias LoadFeedResult = Result<[FeedItem], Error>

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}

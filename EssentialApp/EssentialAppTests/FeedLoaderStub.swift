//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Jacob Rakidzich on 10/25/23.
//

import EssentialFeed
import EssentialFeediOS

class FeedLoaderStub: FeedLoader {
    private let result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
        self.result = result
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}

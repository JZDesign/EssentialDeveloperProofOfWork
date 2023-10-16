//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/13/23.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (LoadFeedResult) -> Void) {
        client.get(from: url) { [weak self] in
            guard let self else { return }
            switch $0 {
            case .success(let result):
                if let items = FeedItemsMapper.map(result.data, response: result.response) {
                    completion(.success(items))
                } else {
                    completion(.failure(Error.invalidData))
                }
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
}

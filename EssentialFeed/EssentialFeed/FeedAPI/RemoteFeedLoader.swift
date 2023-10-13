//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/13/23.
//

import Foundation

public typealias RemoteFeedLoaderResult = Result<[FeedItem], RemoteFeedLoader.Error>

public final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (RemoteFeedLoaderResult) -> Void) {
        client.get(from: url) { [weak self] in
            guard let self else { return }
            switch $0 {
            case .success(let result):
                if let items = FeedItemsMapper.map(result.data, response: result.response) {
                    completion(.success(items))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
}

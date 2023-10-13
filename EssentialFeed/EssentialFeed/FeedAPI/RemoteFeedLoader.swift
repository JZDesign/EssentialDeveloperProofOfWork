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
        client.get(from: url) {
            switch $0 {
            case .success(let result):
                if result.response.statusCode == 200, let items = try? JSONDecoder().decode(Root.self, from: result.data).items.map(\.asFeedItem) {
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
    
    struct Root: Decodable {
        let items: [Item]
        
        struct Item: Decodable {
            let id: UUID
            let description: String?
            let location: String?
            let image: URL
            
            var asFeedItem: FeedItem {
                .init(id: id, description: description, location: location, imageURL: image)
            }
        }
    }
}

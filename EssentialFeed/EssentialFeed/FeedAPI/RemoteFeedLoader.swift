//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/13/23.
//

import Foundation

public final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (RemoteFeedLoader.Error) -> Void) {
        client.get(from: url) {
            switch $0 {
            case .success(let result):
                completion(.invalidData)
                if result.response.statusCode != 200 {
                } else {
                    
                }
            case .failure:
                completion(.connectivity)
            }
        }
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
}

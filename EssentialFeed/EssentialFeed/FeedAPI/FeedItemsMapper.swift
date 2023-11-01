//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/13/23.
//

import Foundation

public enum FeedItemsMapper {
    private static func isOK(_ code: Int) -> Bool {
        code == 200
    }
    
    public static func map(response: HTTPURLResponse, data: Data) throws -> [FeedImage] {
        if isOK(response.statusCode) {
            return try JSONDecoder().decode(Root.self, from: data).items.map(\.asFeedImage)
        } else {
            throw Error.invalidData
        }
    }

    public enum Error: Swift.Error {
        case invalidData
    }
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
}

public struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}

private extension RemoteFeedItem {
    var asFeedImage: FeedImage {
        .init(id: id, description: description, location: location, url: image)
    }
}

//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/13/23.
//

import Foundation

enum FeedItemsMapper {
    private static func isOK(_ code: Int) -> Bool {
        code == 200
    }

    static func map(_ data: Data, response: HTTPURLResponse) -> [FeedItem]? {
        if isOK(response.statusCode), let items = try? JSONDecoder().decode(Root.self, from: data).items.map(\.asFeedItem) {
            return items
        } else {
            return nil
        }
    }
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
}

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}

private extension RemoteFeedItem {
    var asFeedItem: FeedItem {
        .init(id: id, description: description, location: location, imageURL: image)
    }
}

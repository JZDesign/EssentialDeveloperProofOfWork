//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/13/23.
//

import Foundation

enum FeedItemsMapper {
    static func map(_ data: Data, response: HTTPURLResponse) -> [FeedItem]? {
        if response.statusCode == 200, let items = try? JSONDecoder().decode(Root.self, from: data).items.map(\.asFeedItem) {
            return items
        } else {
            return nil
        }
    }
    
    private struct Root: Decodable {
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

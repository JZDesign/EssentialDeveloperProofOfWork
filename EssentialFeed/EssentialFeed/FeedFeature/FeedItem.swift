//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/12/23.
//

import Foundation

public struct FeedItem: Decodable, Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}

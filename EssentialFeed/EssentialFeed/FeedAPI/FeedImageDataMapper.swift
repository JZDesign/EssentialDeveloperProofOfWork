//
//  FeedImageDataMapper.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 11/1/23.
//

import Foundation

public final class FeedImageDataMapper {
    public enum Error: Swift.Error {
        case invalidData
    }

    public static func map(from response: HTTPURLResponse, withData data: Data) throws -> Data {
        guard response.isOK, !data.isEmpty else {
            throw Error.invalidData
        }

        return data
    }
}

//
//  FeedImageDataMapperTests.swift
//  EssentialFeedTests
//
//  Created by Jacob Rakidzich on 11/1/23.
//

import XCTest
import EssentialFeed
import EssentialFeedTestHelpers

class FeedImageDataMapperTests: XCTestCase {

    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let samples = [199, 201, 300, 400, 500]

        try samples.forEach { code in
            XCTAssertThrowsError(
                try FeedImageDataMapper.map(from: HTTPURLResponse(statusCode: code), withData: anyData())
            )
        }
    }

    func test_map_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let emptyData = Data()

        XCTAssertThrowsError(
            try FeedImageDataMapper.map(from: HTTPURLResponse(statusCode: 200), withData: emptyData)
        )
    }

    func test_map_deliversReceivedNonEmptyDataOn200HTTPResponse() throws {
        let nonEmptyData = Data("non-empty data".utf8)

        let result = try FeedImageDataMapper.map(from: HTTPURLResponse(statusCode: 200), withData: nonEmptyData)

        XCTAssertEqual(result, nonEmptyData)
    }

}

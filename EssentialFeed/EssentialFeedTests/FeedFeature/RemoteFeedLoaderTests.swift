//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Jacob Rakidzich on 10/12/23.
//

import XCTest

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoader { }

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }

}

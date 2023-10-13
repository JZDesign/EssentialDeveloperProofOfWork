//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Jacob Rakidzich on 10/12/23.
//

import XCTest
import EssentialFeed

class HTTPClientSpy: HTTPClient {
    var requestedURLs = [URL]()
    var completions = [(Error) -> Void]()

    func get(from url: URL, completion: @escaping (Error) -> Void) {
        requestedURLs.append(url)
        completions.append(completion)
    }
    
    func complete(with error: Error, at index: Int = 0) {
        completions[index](error)
    }
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_load_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [URL(string: "http://test.com")!])
    }
    
    func test_load_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()
        let url = URL(string: "http://test.com")!

        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        client.complete(with: NSError())
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func makeSUT(url: URL = URL(string: "http://test.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
}

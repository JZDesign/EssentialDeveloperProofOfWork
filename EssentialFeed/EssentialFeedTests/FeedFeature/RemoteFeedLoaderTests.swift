//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Jacob Rakidzich on 10/12/23.
//

import XCTest
import EssentialFeed

class HTTPClientSpy: HTTPClient {
    var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
    var requestedURLs: [URL] {
        messages.map(\.url)
    }

    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        messages.append((url, completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(with statusCode: Int, data: Data = .init(), at index: Int = 0) {
        let response = HTTPURLResponse(url: requestedURLs[index], statusCode: statusCode, httpVersion: nil, headerFields: .none)!
        messages[index].completion(.success((response, data)))
    }
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_load_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [URL(string: "http://test.com")!])
    }
    
    func test_load_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()
        let url = URL(string: "http://test.com")!

        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.connectivity)) {
            client.complete(with: NSError())
        }
    }

    func test_load_deliversErrorOnNon200HttpResponse() {
        [199, 201, 400, 500].forEach { statusCode in
            let (sut, client) = makeSUT()
            expect(sut, toCompleteWith: .failure(.invalidData)) {
                client.complete(with: statusCode)
            }
        }
    }
    
    func test_load_deliversErrorOn200WithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            client.complete(with: 200, data: "invalid".data(using: .utf8)!)
        }
    }
    
    func test_load_deliversNoItemsOn200WithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            client.complete(with: 200, data: #"{"items": []}"#.data(using: .utf8)!)
        }
    }
    
    // MARK: - Helpers
    
    func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWith result: RemoteFeedLoaderResult,
        file: StaticString = #file,
        line: UInt = #line,
        when action: () -> Void
    ) {
        var results = [RemoteFeedLoaderResult]()
        
        sut.load { result in results.append(result) }
        action()
        
        XCTAssertEqual(results, [result], file: file, line: line)
    }
    
    func makeSUT(url: URL = URL(string: "http://test.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
}

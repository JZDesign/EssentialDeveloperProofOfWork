//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Jacob Rakidzich on 10/12/23.
//

import XCTest
import EssentialFeed

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
        
        expect(sut, toCompleteWith: failure(.connectivity)) {
            client.complete(with: NSError())
        }
    }
    
    func test_load_deliversErrorOnNon200HttpResponse() {
        [199, 201, 400, 500].forEach { statusCode in
            let (sut, client) = makeSUT()
            expect(sut, toCompleteWith: failure(.invalidData)) {
                client.complete(with: statusCode)
            }
        }
    }
    
    func test_load_deliversErrorOn200WithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData)) {
            client.complete(with: 200, data: "invalid".data(using: .utf8)!)
        }
    }
    
    func test_load_deliversNoItemsOn200WithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            client.complete(with: 200, data: #"{"items": []}"#.data(using: .utf8)!)
        }
    }
    
    
    func test_load_deliversItemsOn200WithJSONList() {
        let (sut, client) = makeSUT()
        let item1 = makeItem(imageURL: URL(string: "http://test1.com")!)
        let item2 = makeItem(description: "2", location: "2", imageURL: URL(string: "http://test2.com")!)
        
        expect(sut, toCompleteWith: .success([item1.model, item2.model])) {
            let json = makeItemsJson(items: [item1.json, item2.json])
            client.complete(with: 200, data: try! JSONSerialization.data(withJSONObject: json))
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTisDeallocated() {
        var (sut, client): (RemoteFeedLoader?, HTTPClientSpy) = makeSUT()
        var capturedResults: [LoadFeedResult] = []
        
        sut?.load(completion: { capturedResults.append($0) })
        sut = nil
        
        client.complete(with: 200, data: try! JSONSerialization.data(withJSONObject: makeItemsJson(items: [])))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeItem(id: UUID = .init(), description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String : Encodable]) {
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        return (item, jsonItem(for: item))
    }
    
    private func makeItemsJson(items: [[String : Any]]) -> [String : Any] {
        ["items": items]
    }
    
    private func jsonItem(for item: FeedItem) -> [String : Encodable] {
        [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.imageURL.absoluteString
        ]
    }
    
    private func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWith expectedResult: LoadFeedResult,
        file: StaticString = #file,
        line: UInt = #line,
        when action: () -> Void
    ) {
        var results = [LoadFeedResult]()
        let expectation = expectation(description: "Wait for load completion")
        sut.load { result in
            switch (result, expectedResult) {
            case let (.success(items), .success(expectedItems)):
                XCTAssertEqual(items, expectedItems, file: file, line: line)
            case let (.failure(error as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(error, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) but got \(result) instead")
            }
            expectation.fulfill()
        }
        action()
        wait(for: [expectation], timeout: 0.1)
    }
    
    func failure(_ error: RemoteFeedLoader.Error) -> LoadFeedResult {
        .failure(error)
    }
    
    private func makeSUT(url: URL = URL(string: "http://test.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = createAndTrackMemoryLeaks(HTTPClientSpy())
        let sut = createAndTrackMemoryLeaks(RemoteFeedLoader(url: url, client: client))
        return (sut, client)
    }
}

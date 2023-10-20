//
//  HTTPClientSpy.swift
//  EssentialFeedTests
//
//  Created by Jacob Rakidzich on 10/13/23.
//

import Foundation
import EssentialFeed

class HTTPClientSpy: HTTPClient {
    var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
    var requestedURLs: [URL] {
        messages.map(\.url)
    }

    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
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

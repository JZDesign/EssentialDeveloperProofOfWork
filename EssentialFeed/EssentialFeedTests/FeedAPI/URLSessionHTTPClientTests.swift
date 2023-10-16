//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Jacob Rakidzich on 10/16/23.
//

import XCTest
import EssentialFeed

final class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performsGetRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for completion")
        
        URLProtocolStub.observeRequests { req in
            XCTAssertEqual(req.url, url)
            XCTAssertEqual(req.httpMethod, "GET")

            exp.fulfill()
        }

        makeSUT().get(from: url) { _ in }
          
        wait(for: [exp], timeout: 1.0)
        
    }
    
    func test_getFromURL_failsOnRequestError() {
        let sut = makeSUT()
        let url = anyURL()
        let error = NSError(domain: "any error", code: 1)
        
        let receivedError = resultErrorFor(data: nil, response: nil, error: error) as? NSError
        XCTAssertEqual(receivedError?.code, error.code)
        XCTAssertEqual(receivedError?.domain, error.domain)
        
    }
    
    func test_getFromURL_failsOnAllNilValues() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
    }

    // MARK: - Helpers
    
    private func resultErrorFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Error? {
        var receivedError: Error?

        URLProtocolStub.stub(url: anyURL(), data: data, response: response, error: error)
        
        let exp = expectation(description: "Wait for completion")

        makeSUT(file: file, line: line).get(from: anyURL()) { result in
            switch result {
            case let .failure(err):
                receivedError = err
            default:
                XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> URLSessionHTTPClient {
        createAndTrackMemoryLeaks(URLSessionHTTPClient(session: .shared), file: file, line: line)
    }

}

class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    struct UnexpectedValuesRepresentation: Error {}
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}

class URLProtocolStub: URLProtocol {
    private static var stub: Stub? = nil
    private static var requestObserver: ((URLRequest) -> Void)? = .none
    
    // MARK: URLProtocol
    
    override class func canInit(with request: URLRequest) -> Bool {
        requestObserver?(request)
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        guard let stub = URLProtocolStub.stub else { return }
        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}

    // MARK: Helpers
    
    static func stub(url: URL, data: Data?, response: URLResponse?, error: Error?) {
        stub = Stub(data: data, response: response, error: error)
    }
    
    static func startInterceptingRequests() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        stub = .none
        requestObserver = .none
    }
    
    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
        requestObserver = observer
    }
    
    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }
}

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
        let error = anyNSError()
        
        let receivedError = resultErrorFor(data: nil, response: nil, error: error) as? NSError
        XCTAssertEqual(receivedError?.code, error.code)
        XCTAssertEqual(receivedError?.domain, error.domain)
        
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHttpResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHttpResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHttpResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHttpResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHttpResponse(), error: nil))
    }

    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHttpResponse()
        
        let (receivedResponse, receivedData) = resultValuesFor(data: data, response: response)!
        XCTAssertEqual(receivedData, data)
        XCTAssertEqual(receivedResponse.statusCode, response.statusCode)
        XCTAssertEqual(receivedResponse.url, response.url)
        XCTAssertEqual(receivedResponse.mimeType, response.mimeType)
        XCTAssertEqual(
            receivedResponse.allHeaderFields.map { [$0.key: String(describing: $0.value)]},
            response.allHeaderFields.map { [$0.key: String(describing: $0.value)]}
        )
    }
    
    func test_getFromURL_succeedsOnEmptyDataResponseWithNilData() {
        let response = anyHttpResponse()
        
        let (receivedResponse, receivedData) = resultValuesFor(data: nil, response: response)!
        XCTAssertEqual(receivedData, Data())
        XCTAssertEqual(receivedResponse.statusCode, response.statusCode)
        XCTAssertEqual(receivedResponse.url, response.url)
        XCTAssertEqual(receivedResponse.mimeType, response.mimeType)
        XCTAssertEqual(
            receivedResponse.allHeaderFields.map { [$0.key: String(describing: $0.value)]},
            response.allHeaderFields.map { [$0.key: String(describing: $0.value)]}
        )
    }
    
    // MARK: - Helpers
    
    private func resultValuesFor(
        data: Data?,
        response: URLResponse?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (response: HTTPURLResponse, data: Data)? {
        var receivedResponse: (response: HTTPURLResponse, data: Data)?

        URLProtocolStub.stub(url: anyURL(), data: data, response: response, error: nil)
        
        let exp = expectation(description: "Wait for completion")

        makeSUT(file: file, line: line).get(from: anyURL()) { result in
            switch result {
            case let .success(res):
                receivedResponse = res
            default:
                XCTFail("Expected success, got \(result) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return receivedResponse
    }
    
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
        session.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(error))
            } else if let data, let response = response as? HTTPURLResponse {
                completion(.success((response, data)))
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

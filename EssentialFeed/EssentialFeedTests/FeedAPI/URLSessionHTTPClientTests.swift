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
        assert(receivedResponse: receivedResponse, equals: response)
    }
    
    func test_getFromURL_succeedsOnEmptyDataResponseWithNilData() {
        let response = anyHttpResponse()
        
        let (receivedResponse, receivedData) = resultValuesFor(data: nil, response: response)!
        XCTAssertEqual(receivedData, Data())
        assert(receivedResponse: receivedResponse, equals: response)
    }
    
    // MARK: - Helpers
    
    private func assert(
        receivedResponse: HTTPURLResponse,
        equals response: HTTPURLResponse,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(receivedResponse.statusCode, response.statusCode, file: file, line: line)
        XCTAssertEqual(receivedResponse.url, response.url, file: file, line: line)
        XCTAssertEqual(receivedResponse.mimeType, response.mimeType, file: file, line: line)
        XCTAssertEqual(
            receivedResponse.allHeaderFields.mapValues { String(describing: $0) },
            response.allHeaderFields.mapValues { String(describing: $0) },
            file: file,
            line: line
        )
    }
    
    private func resultValuesFor(
        data: Data?,
        response: URLResponse?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (response: HTTPURLResponse, data: Data)? {
        let result = resultFor(data: data, response: response, error: nil, file: file, line: line)
        
        switch result {
        case let .success(res):
            return res
        default:
            XCTFail("Expected success, got \(result) instead", file: file, line: line)
        }
        return nil
    }
    
    private func resultErrorFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Error? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case let .failure(err):
            return err
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
        }
        
        return nil
    }
    
    private func resultFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString,
        line: UInt
    ) -> HTTPClientResult {
        var receivedResult: HTTPClientResult!

        URLProtocolStub.stub(url: anyURL(), data: data, response: response, error: error)
        
        let exp = expectation(description: "Wait for completion")

        makeSUT().get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    private func makeSUT() -> HTTPClient {
        URLSession.shared
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

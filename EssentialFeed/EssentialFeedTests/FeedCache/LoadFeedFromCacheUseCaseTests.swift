//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Jacob Rakidzich on 10/17/23.
//

import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.recievedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        sut.load { _ in }
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
//
//    func test_load_deletesCacheOnRetrievalError() {
//        var (sut, store): (LocalFeedLoader?, FeedStoreSpy) = makeSUT()
//        var result = [Error?]()
//        sut?.load() { _ in }
//        sut = nil
//        store.completeRetrieval(with: .init())
//        XCTAssertEqual(result.count, 0)
//    }
    
    // MARK: Helpers
    
    func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = createAndTrackMemoryLeaks(FeedStoreSpy(), file: file, line: line)
        let loader = createAndTrackMemoryLeaks(LocalFeedLoader(store:  store, currentDate: currentDate), file: file, line: line)
        return (loader, store)
    }
    
    func expect(_ sut: LocalFeedLoader, toCompleteLoadWithError expectedError: EquatableError?, file: StaticString = #file, line: UInt = #line, when action: () -> Void) {
        var recievedError: Error?
        
        let expectation = expectation(description: #function)
        
        sut.load {
            switch $0 {
            case .success:
                XCTFail(#function)
            case .failure(let error):
                recievedError = error
            }
            expectation.fulfill()
        }
        
        action()
        wait(for: [expectation])
        
        XCTAssertEqual(expectedError, recievedError as? EquatableError, file: file, line: line)
    }
}

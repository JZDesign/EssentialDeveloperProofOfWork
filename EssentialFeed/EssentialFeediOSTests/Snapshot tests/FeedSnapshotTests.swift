//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Jacob Rakidzich on 11/1/23.
//

import XCTest
@testable import EssentialFeediOS
@testable import EssentialFeed

class FeedSnapshotTests: XCTestCase {
    
    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_CONTENT_dark")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_CONTENT_light_extraExtraExtraLarge")

    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()
        
        sut.display(feedWithFailedImageLoading())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
    }
    
    func test_feedWithLoadMoreIndicator() {
        let sut = makeSUT()
        
        sut.display(feedWithLoadMoreIndicator())
        
        record(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_LOAD_MORE_INDICATOR_light")
        record(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_LOAD_MORE_INDICATOR_dark")
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.simulateAppearance()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    private func feedWithLoadMoreIndicator() -> [CellController] {
        let stub = feedWithContent().last!
        let cellController = FeedImageCellController(viewModel: stub.viewModel, delegate: stub, selection: {})
        stub.controller = cellController
        
        let loadMore = LoadMoreCellController()
        loadMore.display(ResourceLoadingViewModel(isLoading: true))
        return [
            CellController(id: UUID(), cellController),
            CellController(id: UUID(), loadMore)
        ]
    }
}

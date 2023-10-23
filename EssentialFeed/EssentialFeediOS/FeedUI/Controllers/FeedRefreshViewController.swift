//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Jacob Rakidzich on 10/23/23.
//

import UIKit
import EssentialFeed

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    var _view = UIRefreshControl()
    private(set) lazy var view = loadView()
    private let delegate: FeedRefreshViewControllerDelegate

    init(delegate: FeedRefreshViewControllerDelegate) {
            self.delegate = delegate
        }

    @objc func refresh() {
        delegate.didRequestFeedRefresh()
    }
    
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }

    private func loadView() -> UIRefreshControl {
        let view = _view
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}

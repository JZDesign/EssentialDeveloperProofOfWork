//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Jacob Rakidzich on 10/23/23.
//

import UIKit
import EssentialFeed

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    var _view = UIRefreshControl()
    private(set) lazy var view = loadView()
    private let loadFeed: () -> Void

    init(loadFeed: @escaping () -> Void) {
        self.loadFeed = loadFeed
    }

    @objc func refresh() {
        loadFeed()
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

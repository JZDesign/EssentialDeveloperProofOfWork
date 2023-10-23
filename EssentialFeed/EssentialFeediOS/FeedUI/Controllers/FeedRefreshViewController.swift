//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Jacob Rakidzich on 10/23/23.
//

import UIKit
import EssentialFeed

final class FeedRefreshViewController: NSObject {
    var _view = UIRefreshControl()
    private(set) lazy var view = binded({ [weak self] in self?._view ?? UIRefreshControl() })
    private let viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }

    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    private func binded(_ view: @escaping () -> UIRefreshControl) -> UIRefreshControl {
        viewModel.onLoadingStateChange = { isLoading in
            let _view = view()
            if isLoading {
                _view.beginRefreshing()
            } else {
                _view.endRefreshing()
            }
        }
        let _view = view()
        _view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return _view
    }
}

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
    private let presenter: FeedPresenter
    
    init(presenter: FeedPresenter) {
        self.presenter = presenter
    }

    @objc func refresh() {
        presenter.loadFeed()
    }
    
    
    func display(isLoading: Bool) {
        if isLoading {
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

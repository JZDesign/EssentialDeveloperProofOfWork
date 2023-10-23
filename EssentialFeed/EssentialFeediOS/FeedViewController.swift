//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Jacob Rakidzich on 10/23/23.
//

import Foundation
import UIKit
import EssentialFeed


public final class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    
    private var hasAppeared = false
    
    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        guard hasAppeared else {
            hasAppeared = true
            load()
            return
        }
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()

        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

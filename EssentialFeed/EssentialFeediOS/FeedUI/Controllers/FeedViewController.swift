//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Jacob Rakidzich on 10/23/23.
//

import Foundation
import UIKit

public protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, FeedErrorView {
    public var delegate: FeedViewControllerDelegate?

    private var cellControllers = [IndexPath: FeedImageCellController]()

    private var hasAppeared = false

    @IBOutlet private(set) public var errorView: ErrorView?

    private var loadingControllers = [IndexPath: FeedImageCellController]()

    private var tableModel = [FeedImageCellController]() {
        didSet { tableView.reloadData() }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func display(_ cellControllers: [FeedImageCellController]) {
        loadingControllers = [:]
        tableModel = cellControllers
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.sizeTableHeaderToFit()
    }

    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        guard hasAppeared else {
            hasAppeared = true
            refresh()
            
            return
        }
    }
    
    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    public func display(_ viewModel: FeedErrorViewModel) {
        errorView?.message = viewModel.message
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(forRowAt: indexPath).view(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    // MARK: - Prefetching
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }

    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        loadingControllers[indexPath]?.cancelLoad()
        loadingControllers[indexPath] = nil
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
    }
}

extension UITableView {
    func sizeTableHeaderToFit() {
        guard let header = tableHeaderView else { return }

        let size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

        let needsFrameUpdate = header.frame.height != size.height
        if needsFrameUpdate {
            header.frame.size.height = size.height
            tableHeaderView = header
        }
    }
}

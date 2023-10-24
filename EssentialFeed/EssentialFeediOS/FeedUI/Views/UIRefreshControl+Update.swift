//
//  UIRefreshControl+Update.swift
//  EssentialFeediOS
//
//  Created by Jacob Rakidzich on 10/24/23.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}

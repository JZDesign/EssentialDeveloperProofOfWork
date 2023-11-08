//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Jacob Rakidzich on 10/23/23.
//

import UIKit
import EssentialFeed

public final class FeedPresenter {
    private init() { }

    static var title: String {
        NSLocalizedString(
            "FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: EssentialFeediOSBundle.get(),
            comment: "Title for the feed view"
        )
    }
}

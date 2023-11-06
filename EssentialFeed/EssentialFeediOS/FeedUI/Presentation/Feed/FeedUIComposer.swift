//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Jacob Rakidzich on 10/23/23.
//

import UIKit
import Combine
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(
        feedLoader: @escaping () -> AnyPublisher<Paginated<FeedImage>, Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
        selection: @escaping (FeedImage) -> Void = { _ in }
    ) -> ListViewController {
        let presentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>(loader: feedLoader)
        
        let feedController = ListViewController.makeWith(FeedPresenter.title)
        feedController.onRefresh = presentationAdapter.loadResource

        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(controller: feedController, imageLoader: imageLoader, selection: selection),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: { $0 }
        )
        return feedController
    }
}

private extension ListViewController {
    static func makeWith(_ title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.title = title
        return feedController
    }
}

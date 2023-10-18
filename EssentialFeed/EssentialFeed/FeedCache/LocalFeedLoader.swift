//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/17/23.
//

import Foundation

public class LocalFeedLoader {
    let store: FeedStore
    let currentDate: () -> Date
    public typealias SaveResult = (Error?) -> Void
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    public func load(completion: @escaping (LoadFeedResult) -> Void) {
        store.retieve {
            switch $0 {
            case .empty:
                completion(.success([]))
            case let .found(images, timestamp):
                completion(.success(images.map(\.asModel)))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    public func save(_ images: [FeedImage], completion: @escaping SaveResult = { _ in }) {
        store.deleteCachedFeed { [weak self] error in
            guard let self else { return }
            if let error {
                completion(error)
            } else {
                self.cache(images, with: completion)
            }
        }
    }
    
    private func cache(_ images: [FeedImage], with completion: @escaping SaveResult) {
        store.insertImages(images.map(\.asLocal), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

public extension FeedImage {
    var asLocal: LocalFeedImage {
        .init(id: id, description: description, location: location, imageURL: url)
    }
}

public extension LocalFeedImage {
    var asModel: FeedImage {
        .init(id: id, description: description, location: location, url: imageURL)
    }
}

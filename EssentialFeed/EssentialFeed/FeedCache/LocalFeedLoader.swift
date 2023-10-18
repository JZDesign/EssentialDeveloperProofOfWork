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
        store.retieve { [weak self] in
            guard let self else { return }
            switch $0 {
            case let .found(images, timestamp) where self.validate(timestamp):
                completion(.success(images.map(\.asModel)))
            case let .failure(error):
                store.deleteCachedFeed { _ in }
                completion(.failure(error))
            case .empty, .found:
                completion(.success([]))
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
    
    private func validate(_ date: Date) -> Bool {
        if let maxAge = date.adding(days: 7) {
            return currentDate() < maxAge
        } else {
            return false
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

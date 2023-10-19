//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/17/23.
//

import Foundation

public class LocalFeedLoader: FeedLoader {
    let store: FeedStore
    let currentDate: () -> Date
    public typealias SaveResult = (Error?) -> Void
    lazy var cachePolicy = FeedCachePolicy(currentDate: currentDate)
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func load(completion: @escaping (LoadFeedResult) -> Void) {
        store.retieve { [weak self] in
            guard let self else { return }
            switch $0 {
            case let .found(images, timestamp) where self.cachePolicy.validate(timestamp):
                completion(.success(images.map(\.asModel)))
            case let .failure(error):
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
    
    public func validateCache() {
        store.retieve { [weak self] in
            guard let self else { return }
            switch $0 {
            case .failure:
                self.store.deleteCachedFeed { _ in }
            case let .found(_, timestamp) where !self.cachePolicy.validate(timestamp):
                self.store.deleteCachedFeed { _ in }
            default: break
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

public final class FeedCachePolicy {
    let currentDate: () -> Date
    
    init(currentDate: @escaping () -> Date) {
        self.currentDate = currentDate
    }
    
    func validate(_ date: Date) -> Bool {
        if let maxAge = date.adding(days: 7) {
            return currentDate() < maxAge
        } else {
            return false
        }
    }
}

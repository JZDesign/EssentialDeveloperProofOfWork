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
    public typealias SaveResult = Result<Void, Error>
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        store.retrieve { [weak self] in
            guard let self else { return }
            switch $0 {
            case let .success(.some(feed)) where FeedCachePolicy.validate(feed.timestamp, againstDate: self.currentDate()):
                completion(.success(feed.images.map(\.asModel)))
            case let .failure(error):
                completion(.failure(error))
            case .success:
                completion(.success([]))
            }
        }
    }
    
    public func save(_ images: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] deletionResult in
            guard let self else { return }
            switch deletionResult {
            case .success:
                self.cache(images, with: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func validateCache() {
        store.retrieve { [weak self] in
            guard let self else { return }
            switch $0 {
            case .failure:
                self.store.deleteCachedFeed { _ in }
            case let .success(.some(feed)) where !FeedCachePolicy.validate(feed.timestamp, againstDate: self.currentDate()):
                self.store.deleteCachedFeed { _ in }
            default: break
            }
        }
    }
    
    private func cache(_ images: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(images.map(\.asLocal), timestamp: currentDate()) { [weak self] result in
            guard self != nil else { return }
            completion(result)
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

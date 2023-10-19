//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/19/23.
//

import Foundation

public enum FeedCachePolicy {
    static func validate(_ date: Date, againstDate: Date) -> Bool {
        if let maxAge = date.adding(days: 7) {
            return againstDate < maxAge
        } else {
            return false
        }
    }
}

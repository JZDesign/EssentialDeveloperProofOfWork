//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Jacob Rakidzich on 10/24/23.
//

import Foundation

public struct FeedErrorViewModel {
    public let message: String?
    
    public static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    public static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}

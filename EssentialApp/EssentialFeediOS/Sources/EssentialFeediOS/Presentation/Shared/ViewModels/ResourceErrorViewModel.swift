//
//  ResourceErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Jacob Rakidzich on 10/24/23.
//

import Foundation

public struct ResourceErrorViewModel {
    public let message: String?
    
    public static var noError: ResourceErrorViewModel {
        return ResourceErrorViewModel(message: nil)
    }

    public static func error(message: String) -> ResourceErrorViewModel {
        return ResourceErrorViewModel(message: message)
    }
}

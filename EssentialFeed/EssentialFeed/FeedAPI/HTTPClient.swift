//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/13/23.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL)
}

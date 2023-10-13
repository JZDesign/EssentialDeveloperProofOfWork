//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/13/23.
//

import Foundation

public typealias HTTPClientResult = Result<(response: HTTPURLResponse, data: Data), Error>

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
    
}

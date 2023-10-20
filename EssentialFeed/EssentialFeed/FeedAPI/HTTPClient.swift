//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/13/23.
//

import Foundation


public protocol HTTPClient {
    typealias Result = Swift.Result<(response: HTTPURLResponse, data: Data), Error>
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void)
    
}

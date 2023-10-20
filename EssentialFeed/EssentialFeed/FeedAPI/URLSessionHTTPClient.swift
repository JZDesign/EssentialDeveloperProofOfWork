//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/16/23.
//

import Foundation

extension URLSession: HTTPClient {
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        dataTask(with: url) { data, response, error in
            completion(Result {
                if let error {
                    throw error
                } else if let data, let response = response as? HTTPURLResponse {
                    return (response, data)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }.resume()
    }
}

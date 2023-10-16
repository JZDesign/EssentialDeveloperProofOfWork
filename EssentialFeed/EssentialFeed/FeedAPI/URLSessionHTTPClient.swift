//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/16/23.
//

import Foundation

extension URLSession: HTTPClient {
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(error))
            } else if let data, let response = response as? HTTPURLResponse {
                completion(.success((response, data)))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}

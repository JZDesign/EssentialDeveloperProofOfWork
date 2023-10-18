//
//  Date+Helpers.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/18/23.
//

import Foundation

public extension Date {
    func adding(days: Int) -> Date? {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)
    }
    
    func adding(seconds: Int) -> Date? {
        Calendar(identifier: .gregorian).date(byAdding: .second, value: seconds, to: self)
    }
}

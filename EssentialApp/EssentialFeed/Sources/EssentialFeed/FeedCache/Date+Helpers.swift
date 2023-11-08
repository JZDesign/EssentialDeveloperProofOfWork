//
//  Date+Helpers.swift
//  EssentialFeed
//
//  Created by Jacob Rakidzich on 10/18/23.
//

import Foundation

public extension Date {
    func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date? {
        calendar.date(byAdding: .day, value: days, to: self)
    }
    
    func adding(minutes: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date? {
        adding(seconds: 60 * minutes, calendar: calendar)
    }

    func adding(seconds: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date? {
        calendar.date(byAdding: .second, value: seconds, to: self)
    }
}

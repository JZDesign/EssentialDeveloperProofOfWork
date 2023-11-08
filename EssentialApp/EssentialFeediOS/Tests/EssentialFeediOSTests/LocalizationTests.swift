//
//  LocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Jacob Rakidzich on 10/23/23.
//

import XCTest
@testable import EssentialFeediOS

final class FeedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = EssentialFeediOSBundle.testBundle
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
}

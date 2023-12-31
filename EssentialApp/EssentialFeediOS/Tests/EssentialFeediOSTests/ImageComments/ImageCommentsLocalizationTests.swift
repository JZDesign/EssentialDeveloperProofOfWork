//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Jacob Rakidzich on 11/2/23.
//

import XCTest
import EssentialFeediOS

class ImageCommentsLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = EssentialFeediOSBundle.testBundle

        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
}

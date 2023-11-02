//
//  ImageCommentPresenterTests.swift
//  EssentialFeediOSTests
//
//  Created by Jacob Rakidzich on 11/2/23.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

final class ImageCommentPresenterTests: XCTestCase {
    func test_map_createsViewModels() {
        let now = Date()
        
        let comments = [
            ImageComment(
                id: UUID(),
                message: "a message",
                createdAt: now.adding(minutes: -5)!,
                username: "a username"),
            ImageComment(
                id: UUID(),
                message: "another message",
                createdAt: now.adding(days: -1)!,
                username: "another username")
        ]
        
        let viewModel = ImageCommentsPresenter.map(comments)
        
        XCTAssertEqual(viewModel.comments, [
            ImageCommentViewModel(
                message: "a message",
                date: "5 minutes ago",
                username: "a username"
            ),
            ImageCommentViewModel(
                message: "another message",
                date: "1 day ago",
                username: "another username"
            )
        ])
    }
}

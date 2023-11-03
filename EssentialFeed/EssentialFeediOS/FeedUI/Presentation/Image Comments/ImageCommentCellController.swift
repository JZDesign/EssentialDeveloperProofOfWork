//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Jacob Rakidzich on 11/3/23.
//

import UIKit
import EssentialFeed

public class ImageCommentCellController: NSObject, UITableViewDataSource {
    private let model: ImageCommentViewModel

    public init(model: ImageCommentViewModel) {
        self.model = model
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.messageLabel.text = model.message
        cell.usernameLabel.text = model.username
        cell.dateLabel.text = model.date
        return cell
    }
}

public final class ImageCommentCell: UITableViewCell {
    @IBOutlet private(set) public var messageLabel: UILabel!
    @IBOutlet private(set) public var usernameLabel: UILabel!
    @IBOutlet private(set) public var dateLabel: UILabel!
}

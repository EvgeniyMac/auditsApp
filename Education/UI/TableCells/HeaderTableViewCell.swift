//
//  HeaderTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 01/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class HeaderTableViewCell: UITableViewCell {

    public var isClippedTop: Bool = false {
        didSet {
            updateCellLayout()
        }
    }

    private struct Constants {
        static let topInsetDefault = CGFloat(20)
        static let topInsetClipped = CGFloat(8)
    }

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var actionContainer: UIView!
    @IBOutlet private weak var actionLabel: UILabel!
    @IBOutlet private weak var labelTopConstraint: NSLayoutConstraint!

    private var action: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.titleLabel.font = AppStyle.Font.medium(20)
        self.titleLabel.textColor = AppStyle.Color.textMain
        self.actionLabel.font = AppStyle.Font.regular(16)
        self.actionLabel.textColor = AppStyle.Color.textAction
    }

    // MARK: - Public
    public func setupWith(title: String?,
                          actionTitle: String?,
                          action: (() -> Void)?) {
        self.titleLabel.text = title
        self.actionLabel.text = actionTitle
        self.action = action
        if actionTitle == nil {
            self.actionContainer.removeFromSuperview()
        }
    }

    // MARK: - Actions
    @IBAction private func didPressActionButton(sender: Any) {
        self.action?()
    }

    // MARK: - Private
    private func updateCellLayout() {
        if isClippedTop {
            self.labelTopConstraint.constant = Constants.topInsetClipped
        } else {
            self.labelTopConstraint.constant = Constants.topInsetDefault
        }
    }
}

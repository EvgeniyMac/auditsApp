//
//  CourseTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 20/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class CourseTableViewCell: UITableViewCell {

    private struct Constants {
        static let topInsetDefault = CGFloat(20)
        static let topInsetClipped = CGFloat.zero
    }

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var markImageView: UIImageView!

    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var stateLabel: MarginLabel!
    @IBOutlet weak var bookmarkImageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!

    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var passedUsersLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!

    @IBOutlet private weak var logoImageTopConstraint: NSLayoutConstraint!

    public var isClippedTop: Bool = false {
        didSet {
            updateCellLayout()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.logoImageView.layer.cornerRadius = AppStyle.CornerRadius.default
        self.logoImageView.layer.masksToBounds = true
        self.logoImageView.contentMode = .scaleAspectFill

        self.stateLabel.insets = UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5)
        self.stateLabel.layer.cornerRadius = AppStyle.CornerRadius.label
        self.stateLabel.layer.borderWidth = AppStyle.Border.label
        self.stateLabel.layer.masksToBounds = true

        self.titleLabel.font = AppStyle.Font.medium(18)

        let regularFont = AppStyle.Font.regular(12)
        self.rateLabel.font = regularFont
        self.passedUsersLabel.font = regularFont
        self.durationLabel.font = regularFont

        self.rateLabel.textColor = AppStyle.Color.textMainBrightened
        self.passedUsersLabel.textColor = AppStyle.Color.textMainBrightened
        self.durationLabel.textColor = AppStyle.Color.textMainBrightened

        [self.typeLabel, self.stateLabel].forEach { (label) in
            label?.font = regularFont
            label?.textColor = AppStyle.Color.blackBrightened
        }

        // required title label volume is 3 lines
        self.titleLabel.numberOfLines = 3

        // setting low H-resistance to compress course type instead of its state
        self.typeLabel.setContentCompressionResistancePriority(.defaultLow,
                                                               for: .horizontal)

        let color = AppStyle.Color.separator.withAlphaComponent(0.3)
        self.separatorView.backgroundColor = color
    }

    // MARK: - Private
    private func updateCellLayout() {
        if isClippedTop {
            self.logoImageTopConstraint.constant = Constants.topInsetClipped
        } else {
            self.logoImageTopConstraint.constant = Constants.topInsetDefault
        }
    }
}

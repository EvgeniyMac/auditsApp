//
//  HelpChatCollectionViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 25.12.2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class HelpChatCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    private static let attributes = AppStyle
        .stringAttributes(font: AppStyle.Font.regular(14),
                          color: AppStyle.Color.textMainBrightened,
                          lineSpacing: 1)

    override func awakeFromNib() {
        super.awakeFromNib()

        self.containerView.layer.cornerRadius = AppStyle.CornerRadius.default
        self.containerView.layer.masksToBounds = true
        self.logoImageView.contentMode = .scaleAspectFit

        self.titleLabel.textColor = AppStyle.Color.textMainBrightened
        self.titleLabel.font = AppStyle.Font.regular(14)
        self.titleLabel.numberOfLines = 0
    }

    public func setup(titleText: String?) {
        let textAttributes = HelpChatCollectionViewCell.attributes
        let text = titleText?.attributed(with: textAttributes)
        self.titleLabel.attributedText = text
    }
}

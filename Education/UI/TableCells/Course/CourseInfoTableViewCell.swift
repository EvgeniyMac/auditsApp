//
//  CourseInfoTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 02/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class CourseInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var markImageView: UIImageView!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var stateLabel: MarginLabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!

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
        self.priceLabel.font = AppStyle.Font.medium(14)

        self.titleLabel.textColor = AppStyle.Color.textSelected
        self.priceLabel.textColor = AppStyle.Color.green

        [self.typeLabel, self.stateLabel].forEach { (label) in
            label?.font = AppStyle.Font.regular(12)
            label?.textColor = AppStyle.Color.textMainBrightened
        }

        self.titleLabel.numberOfLines = 0

        // setting low H-resistance to compress course type instead of its state
        self.typeLabel.setContentCompressionResistancePriority(.defaultLow,
                                                               for: .horizontal)
    }
}

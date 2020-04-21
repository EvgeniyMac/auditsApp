//
//  CourseCollectionViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 25/05/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class CourseCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var logoImageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var complexityImageView: UIImageView!
    @IBOutlet weak var complexityLabel: UILabel!
    @IBOutlet weak var rateImageView: UIImageView!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var passedUsersImageView: UIImageView!
    @IBOutlet weak var passedUsersLabel: UILabel!

    override func awakeFromNib() {
        self.logoImageView.layer.cornerRadius = AppStyle.CornerRadius.default
        self.logoImageView.layer.masksToBounds = true
        self.logoImageView.contentMode = .scaleAspectFill

        let regularFont = AppStyle.Font.regular(14)
        self.durationLabel.font = regularFont
        self.complexityLabel.font = regularFont
        self.rateLabel.font = regularFont
        self.passedUsersLabel.font = regularFont

        self.titleLabel.font = AppStyle.Font.light(18)
    }
}

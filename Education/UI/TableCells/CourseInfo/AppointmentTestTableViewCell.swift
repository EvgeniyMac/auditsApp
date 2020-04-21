//
//  AppointmentTestTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 07.12.2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class AppointmentTestTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var stateImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.containerView.layer.cornerRadius = AppStyle.CornerRadius.label
        self.containerView.layer.masksToBounds = true
        let borderColor = AppStyle.Color.custom(hex: 0xEEEEEE)
        self.containerView.layer.borderColor = borderColor.cgColor
        self.containerView.layer.borderWidth = 1.0

        self.titleLabel.textColor = AppStyle.Color.textSelected
        self.titleLabel.font = AppStyle.Font.medium(16)
        self.titleLabel.numberOfLines = 0
    }
}

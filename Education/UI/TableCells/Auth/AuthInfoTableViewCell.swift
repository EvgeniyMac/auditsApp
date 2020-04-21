//
//  AuthInfoTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 28/09/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class AuthInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.titleLabel.textColor = AppStyle.Color.textMain
        self.titleLabel.font = AppStyle.Font.semibold(24)
        self.titleLabel.numberOfLines = 0

        self.subtitleLabel.textColor = AppStyle.Color.textSupplementary
        self.subtitleLabel.font = AppStyle.Font.regular(16)
        self.subtitleLabel.numberOfLines = 0
    }
}

//
//  DoubleLabelTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 24.02.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import UIKit

class DoubleLabelTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.titleLabel.font = AppStyle.Font.medium(20)
        self.titleLabel.textColor = AppStyle.Color.textMain
        self.titleLabel.numberOfLines = 0

        self.subtitleLabel.font = AppStyle.Font.regular(14)
        self.subtitleLabel.textColor = AppStyle.Color.textMainBrightened
        self.subtitleLabel.numberOfLines = 0

        let lowPrio = UILayoutPriority(rawValue: 100)
        self.subtitleLabel.setContentHuggingPriority(lowPrio,
                                                     for: .vertical)
    }
}

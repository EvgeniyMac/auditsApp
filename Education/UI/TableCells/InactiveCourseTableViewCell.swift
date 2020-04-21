//
//  InactiveCourseTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 03/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class InactiveCourseTableViewCell: UITableViewCell {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        self.logoImageView.layer.cornerRadius = AppStyle.CornerRadius.default
        self.logoImageView.layer.masksToBounds = true

        self.stateLabel.textColor = AppStyle.Color.textMain
        self.stateLabel.font = AppStyle.Font.regular(11)
        self.titleLabel.textColor = AppStyle.Color.textMain
        self.titleLabel.font = AppStyle.Font.light(18)
        self.dateLabel.textColor = AppStyle.Color.textMain
        self.dateLabel.font = AppStyle.Font.light(14)
    }
}

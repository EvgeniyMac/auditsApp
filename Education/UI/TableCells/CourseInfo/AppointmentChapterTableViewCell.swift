//
//  AppointmentChapterTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 01.12.2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class AppointmentChapterTableViewCell: UITableViewCell {

    @IBOutlet weak var stateImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.titleLabel.textColor = AppStyle.Color.textSelected
        self.titleLabel.font = AppStyle.Font.regular(16)
        self.titleLabel.numberOfLines = 0
    }
}

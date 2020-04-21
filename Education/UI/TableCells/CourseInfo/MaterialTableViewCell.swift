//
//  MaterialTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 23/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class MaterialTableViewCell: UITableViewCell {

    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.titleLabel.font = AppStyle.Font.regular(16)
        self.titleLabel.textColor = AppStyle.Color.textMain
        self.titleLabel.numberOfLines = 0
        self.durationLabel.font = AppStyle.Font.regular(12)
        self.durationLabel.textColor = AppStyle.Color.darkGray
    }
}

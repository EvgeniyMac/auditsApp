//
//  ProfileTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 04/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var separatorView: UIView!

    override func awakeFromNib() {
        self.titleLabel.textColor = AppStyle.Color.textMain
        self.titleLabel.font = AppStyle.Font.light(15)
        self.separatorView.backgroundColor = AppStyle.Color.separator
    }
}

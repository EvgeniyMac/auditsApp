//
//  UserInfoTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 04/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class UserInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!

    override func awakeFromNib() {
        self.nameLabel.textColor = AppStyle.Color.textMain
        self.nameLabel.font = AppStyle.Font.light(22)
        self.nameLabel.numberOfLines = 0

        self.roleLabel.textColor = AppStyle.Color.textMain
        self.roleLabel.font = AppStyle.Font.light(15)
        self.roleLabel.numberOfLines = 0
    }
}

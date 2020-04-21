//
//  ButtonTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 17/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var button: CustomButton!

    override func awakeFromNib() {
        self.button.titleLabel?.font = AppStyle.Font.medium(18)
    }
}

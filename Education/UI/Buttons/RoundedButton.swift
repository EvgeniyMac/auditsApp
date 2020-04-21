//
//  RoundedButton.swift
//  Education
//
//  Created by Andrey Medvedev on 03/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()

        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = true
    }
}

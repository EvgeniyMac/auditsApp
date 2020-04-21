//
//  RoundedView.swift
//  Education
//
//  Created by Andrey Medvedev on 03/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class RoundedView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()

        self.layer.cornerRadius = max(self.frame.width, self.frame.height) / 2
        self.layer.masksToBounds = true
    }
}

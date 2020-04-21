//
//  BorderedButton.swift
//  Education
//
//  Created by Andrey Medvedev on 25/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class BorderedButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()

        self.contentEdgeInsets = AppStyle.Inset.buttonConformityOption
        self.layer.borderWidth = AppStyle.Border.button
        self.layer.borderColor = AppStyle.Color.buttonMain.cgColor
    }
}

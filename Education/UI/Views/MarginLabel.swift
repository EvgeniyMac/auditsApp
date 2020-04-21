//
//  MarginLabel.swift
//  Education
//
//  Created by Andrey Medvedev on 25/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class MarginLabel: UILabel {
    var insets = UIEdgeInsets.zero

    override var intrinsicContentSize: CGSize {
        let sizeValue = super.intrinsicContentSize
        return CGSize(width: sizeValue.width + insets.left + insets.right,
                      height: sizeValue.height + insets.top + insets.bottom)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: self.insets))
    }
}

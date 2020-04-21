//
//  UIColor+Additions.swift
//  Education
//
//  Created by Andrey Medvedev on 15/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        assert(red >= 0 && red <= 255, "ERROR: UIColor extension: Invalid red component")
        assert(green >= 0 && green <= 255, "ERROR: UIColor extension: Invalid green component")
        assert(blue >= 0 && blue <= 255, "ERROR: UIColor extension: Invalid blue component")

        self.init(red: CGFloat(red) / 255.0,
                  green: CGFloat(green) / 255.0,
                  blue: CGFloat(blue) / 255.0,
                  alpha: alpha)
    }

    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(red: (hex >> 16) & 0xFF,
                  green: (hex >> 8) & 0xFF,
                  blue: hex & 0xFF,
                  alpha: alpha)
    }
}

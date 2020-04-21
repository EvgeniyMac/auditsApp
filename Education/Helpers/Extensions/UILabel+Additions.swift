//
//  UILabel+Additions.swift
//  Education
//
//  Created by Andrey Medvedev on 04/11/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

extension UILabel {
    func approximateSize() -> CGSize {
        return approximateSize(forWidth: self.frame.width)
    }

    func approximateSize(forWidth: CGFloat) -> CGSize {
        let sizeMax = CGSize(width: forWidth,
                             height: CGFloat.greatestFiniteMagnitude)

        let string = NSString(string: self.text ?? String())
        let frameExpected = string.boundingRect(with: sizeMax,
                                                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                attributes: [NSAttributedString.Key.font: self.font as Any],
                                                context: nil)
        return frameExpected.size
    }
}

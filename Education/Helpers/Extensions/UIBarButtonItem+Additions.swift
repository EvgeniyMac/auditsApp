//
//  UIBarButtonItem+Additions.swift
//  Education
//
//  Created by Andrey Medvedev on 14/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

extension UIBarButtonItem {

    static func spacer(width: CGFloat) -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: .fixedSpace,
                                   target: nil,
                                   action: nil)
        item.width = width
        return item
    }

}

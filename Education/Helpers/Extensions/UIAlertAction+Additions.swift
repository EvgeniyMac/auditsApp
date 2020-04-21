//
//  UIAlertAction+Additions.swift
//  Education
//
//  Created by Andrey Medvedev on 05/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

extension UIAlertAction {
    convenience init(title: String?,
                     style: UIAlertAction.Style,
                     color: UIColor,
                     handler: ((UIAlertAction) -> Void)?) {
        self.init(title: title, style: style, handler: handler)
        self.setValue(color, forKey: "titleTextColor")
    }
}

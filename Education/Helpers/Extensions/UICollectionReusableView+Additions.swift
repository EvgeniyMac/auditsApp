//
//  UICollectionReusableView+Additions.swift
//  Education
//
//  Created by Andrey Medvedev on 17/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

extension UICollectionReusableView {
    static func viewReuseIdentifier() -> String {
        return String(describing: self)
    }
}

//
//  AppearingNavigationLabel.swift
//  Education
//
//  Created by Andrey Medvedev on 19/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class AppearingNavigationLabel: UILabel {

    var totalAppearanceValueMin = CGFloat(0)

    public func updateTitleView(value: CGFloat) {
        let valuesRatio = value / totalAppearanceValueMin
        self.alpha = max(AppStyle.Alpha.hidden,
                         min(AppStyle.Alpha.default,
                             valuesRatio))
    }
}

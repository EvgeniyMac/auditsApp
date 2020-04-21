//
//  CustomNavigationBar.swift
//  Education
//
//  Created by Andrey Medvedev on 06/11/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class CustomNavigationBar: UINavigationBar {

    override func layoutSubviews() {
        super.layoutSubviews()

        for view in subviews {
            setupMargins(forView: view)
        }
    }

    // MARK: - Private
    private func setupMargins(forView: UIView) {
        if #available(iOS 13.0, *) {
            let margins = forView.layoutMargins
            let custom = AppStyle.NavigationBar.layoutMargins
            var frame = forView.frame

            let leftOffset = custom.left - margins.left
            let rightOffset = custom.right - margins.right
            frame.origin.x = leftOffset
            frame.size.width -= (leftOffset + rightOffset)
            forView.frame = frame
        } else {
            forView.layoutMargins = AppStyle.NavigationBar.layoutMargins
        }
    }
}

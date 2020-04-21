//
//  CustomButton.swift
//  Education
//
//  Created by Andrey Medvedev on 20/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        configureUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureUI()
    }

    private func configureUI() {
        self.layer.cornerRadius = AppStyle.CornerRadius.button
        self.layer.masksToBounds = true
        self.backgroundColor = AppStyle.Color.buttonMain
        self.titleLabel?.font = AppStyle.Font.medium(14)
        self.setTitleColor(AppStyle.Color.buttonSupplementary, for: .normal)
        self.contentEdgeInsets = AppStyle.Inset.buttonDefault
    }
}

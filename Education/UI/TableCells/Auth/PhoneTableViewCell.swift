//
//  PhoneTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 17/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class PhoneTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var separatorView: UIView!

    public var onPressCountryCode: (() -> Void)?

    @IBOutlet private weak var verticalInsetConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        self.titleLabel.font = AppStyle.Font.regular(14)
        self.titleLabel.textColor = AppStyle.Color.textSupplementary

        self.countryCodeLabel.font = AppStyle.Font.regular(16)
        self.countryCodeLabel.textColor = AppStyle.Color.textMain

        self.phoneTextField.font = AppStyle.Font.regular(16)
        self.phoneTextField.textColor = AppStyle.Color.textMain
        self.phoneTextField.alpha = 0.64
        self.phoneTextField.keyboardType = .numberPad

        self.verticalInsetConstraint.constant = UIDevice().iPhones_4_4S ? CGFloat(10) : CGFloat(25)
    }

    // MARK: - Actions
    @IBAction private func didPressButton(_ sender: Any) {
        self.onPressCountryCode?()
    }
}

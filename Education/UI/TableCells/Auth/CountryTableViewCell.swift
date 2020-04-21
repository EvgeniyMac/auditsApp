//
//  CountryTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 17/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class CountryTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!

    public var onPressCountryName: (() -> Void)?

    override func awakeFromNib() {
        self.titleLabel.font = AppStyle.Font.regular(16)
        self.titleLabel.textColor = AppStyle.Color.textSecondary
    }

    // MARK: - Actions
    @IBAction private func didPressButton(_ sender: Any) {
        self.onPressCountryName?()
    }
}

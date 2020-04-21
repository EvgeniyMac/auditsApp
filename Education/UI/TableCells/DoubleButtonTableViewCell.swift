//
//  DoubleButtonTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 13.12.2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class DoubleButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var leftButton: CustomButton!
    @IBOutlet weak var rightButton: CustomButton!

    var onPressLeft: (() -> Void)?
    var onPressRight: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.stackView.distribution = .fillEqually
        self.stackView.spacing = CGFloat(13)

        self.leftButton.titleLabel?.font = AppStyle.Font.medium(14)
        self.rightButton.titleLabel?.font = AppStyle.Font.bold(14)
    }

    // MARK: - Actions
    @IBAction func didPressButton(_ sender: Any) {
        if self.leftButton == (sender as? CustomButton) {
            self.onPressLeft?()
        }
        if self.rightButton == (sender as? CustomButton)  {
            self.onPressRight?()
        }
    }

}

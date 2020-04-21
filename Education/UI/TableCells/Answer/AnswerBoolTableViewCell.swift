//
//  AnswerBoolTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 29/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class AnswerBoolTableViewCell: UITableViewCell {

    @IBOutlet weak var trueButton: CustomButton!
    @IBOutlet weak var falseButton: CustomButton!
    var onPressTrueButton: (() -> Void)?
    var onPressFalseButton: (() -> Void)?

    override func awakeFromNib() {
        let trueTitle = Localization.string("answer_bool_cell.true_button")
        self.trueButton.setTitle(trueTitle, for: .normal)
        self.trueButton.setTitleColor(AppStyle.Color.buttonSupplementary, for: .normal)
        self.trueButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)

        let falseTitle = Localization.string("answer_bool_cell.false_button")
        self.falseButton.setTitle(falseTitle, for: .normal)
        self.falseButton.setTitleColor(AppStyle.Color.buttonSupplementary, for: .normal)
        self.falseButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    }

    @IBAction private func didPressTrueButton(_ sender: Any) {
        self.onPressTrueButton?()
    }

    @IBAction private func didPressFalseButton(_ sender: Any) {
        self.onPressFalseButton?()
    }
}

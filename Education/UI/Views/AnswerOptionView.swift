//
//  AnswerOptionView.swift
//  Education
//
//  Created by Andrey Medvedev on 14/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class AnswerOptionView: UIView {

    enum State {
        case initial
        case selected
        case unselected(isActive: Bool)
    }

    var onSelectOption: ((Bool) -> Void)?
    var state = State.initial {
        didSet {
            self.updateUI()
        }
    }
    var selection = OptionSelectionType.single {
        didSet {
            self.updateUI()
        }
    }
    var isOptionSelected: Bool {
        switch self.state {
        case .selected:
            return true
        default:
            return false
        }
    }

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var optionButton: UIButton!

    static func instanceFromNib() -> AnswerOptionView? {
        if let view = AnswerOptionView.fromNib() as? AnswerOptionView {
            view.setup()
            view.updateUI()

            return view
        }

        return nil
    }

    // MARK: - Actions
    @IBAction private func didPressOptionButton(_ sender: Any) {
        self.onSelectOption?(self.isOptionSelected)
    }

    // MARK: - Private
    private func setup() {
        self.containerView.layer.cornerRadius = AppStyle.CornerRadius.default
        self.containerView.layer.masksToBounds = true
        self.containerView.layer.borderWidth = AppStyle.Border.selection
        self.containerView.layer.borderColor = AppStyle.Color.orange.cgColor

        self.optionLabel.font = AppStyle.Font.medium(16)
        self.optionLabel.textColor = AppStyle.Color.textMain
        self.optionLabel.numberOfLines = 0
    }

    private func updateUI() {
        switch self.state {
        case .initial:
            self.statusImage.isHidden = true
            self.optionLabel.textColor = AppStyle.Color.darkGray
            self.containerView.layer.borderWidth = AppStyle.Border.none
            self.containerView.backgroundColor = AppStyle.Color.optionMain
        case .selected:
            self.statusImage.isHidden = false
            self.optionLabel.textColor = AppStyle.Color.darkGray
            self.containerView.layer.borderWidth = AppStyle.Border.selection
            self.containerView.backgroundColor = AppStyle.Color.optionMain
        case .unselected(let isActive):
            self.statusImage.isHidden = true
            self.optionLabel.textColor = AppStyle.Color.gray
            self.containerView.layer.borderWidth = AppStyle.Border.none

            if isActive {
                self.containerView.backgroundColor = AppStyle.Color.optionMain
            } else {
                self.containerView.backgroundColor = AppStyle.Color.optionSecondary
            }
        }
    }
}

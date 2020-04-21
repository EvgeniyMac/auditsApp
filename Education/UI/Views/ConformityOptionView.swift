//
//  ConformityOptionView.swift
//  Education
//
//  Created by Andrey Medvedev on 31/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class ConformityOptionView: UIView {

    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet private weak var optionButton: BorderedButton!

    var onSelectOption: (() -> Void)?

    static func instanceFromNib() -> ConformityOptionView? {
        if let view = ConformityOptionView.fromNib() as? ConformityOptionView {
            view.setup()

            return view
        }

        return nil
    }

    // MARK: - Actions
    @IBAction private func didPressOptionButton(_ sender: Any) {
        self.onSelectOption?()
    }

    // MARK: - Private
    private func setup() {
        self.optionLabel.numberOfLines = 0
        self.optionLabel.font = AppStyle.Font.regular(20)
        self.optionLabel.textColor = AppStyle.Color.textMain
    }
}

//
//  ConformityResultView.swift
//  Education
//
//  Created by Andrey Medvedev on 31/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class ConformityResultView: UIView{

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!

    var onCancelResult: (() -> Void)?

    static func instanceFromNib() -> ConformityResultView? {
        if let view = ConformityResultView.fromNib() as? ConformityResultView {
            view.setup()

            return view
        }

        return nil
    }

    // MARK: - Actions
    @IBAction private func didPressCancelButton(_ sender: Any) {
        self.onCancelResult?()
    }

    // MARK: - Private
    private func setup() {
        self.resultLabel.numberOfLines = 0
        self.resultLabel.font = AppStyle.Font.regular(20)

        let cancelImage = UIImage(named: "answer_cancel_icon")?
            .withRenderingMode(.alwaysTemplate)
        self.cancelButton.tintColor = AppStyle.Color.supplementary
        self.cancelButton.setImage(cancelImage, for: .normal)
    }
}

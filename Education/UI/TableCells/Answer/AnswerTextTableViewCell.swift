//
//  AnswerTextTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 29/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class AnswerTextTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var separatorView: UIView!

    var onChangeText: ((String) -> Void)? {
        didSet {
            self.onChangeText?(self.textField.text ?? String())
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.textField.delegate = self
        self.separatorView.backgroundColor = AppStyle.Color.separator
    }

    // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        onChangeText?(textField.text ?? String())
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = textField.text,
            let textRange = Range(range, in: text) else {
                onChangeText?(textField.text ?? String())
                return true
        }

        let updatedText = text.replacingCharacters(in: textRange, with: string)
        onChangeText?(updatedText)

        return true
    }

}

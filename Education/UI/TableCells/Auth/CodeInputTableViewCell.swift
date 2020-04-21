//
//  CodeInputTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 02/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class CodeInputTableViewCell: UITableViewCell {

    var onChangedInput: ((String) -> Void)?
    var onCompletedInput: ((String) -> Void)?

    private let stubString = "\u{200B}"

    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var textField5: UITextField!
    @IBOutlet weak var textField6: UITextField!

    @IBOutlet weak var underlineView1: UIView!
    @IBOutlet weak var underlineView2: UIView!
    @IBOutlet weak var underlineView3: UIView!
    @IBOutlet weak var underlineView4: UIView!
    @IBOutlet weak var underlineView5: UIView!
    @IBOutlet weak var underlineView6: UIView!

    private var textFields = [UITextField]()
    private var codeLength: Int {
        return self.textFields.count
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.textFields = [textField1,
                           textField2,
                           textField3,
                           textField4,
                           textField5,
                           textField6]

        self.textFields.forEach { (textField) in
            setupTextField(textField)
        }
        self.textFields.last?.returnKeyType = .done

        [underlineView1,
         underlineView2,
         underlineView3,
         underlineView4,
         underlineView5,
         underlineView6].forEach { (view) in
            view?.backgroundColor = AppStyle.Color.supplementary
        }
    }

    // MARK: - Public
    public func resetTextFields() {
        self.textFields.forEach { (textField) in
            textField.text = nil
        }
    }

    // MARK: - Actions
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let index = self.textFields.firstIndex(where: { (item) -> Bool in
            return item == textField
        }) else {
            return
        }

        let text = textField.text?.replacingOccurrences(of: self.stubString, with: String())
        if text?.isEmpty ?? true {
            self.onChangedInput?(String())
            if index > 0 {
                self.textFields[index - 1].becomeFirstResponder()
            }
        } else {
            let code = textFields
                .compactMap({ $0.text })
                .joined()
                .replacingOccurrences(of: self.stubString, with: String())
            self.onChangedInput?(code)

            if index < self.textFields.count - 1 {
                self.textFields[index + 1].becomeFirstResponder()
            } else {
                if code.count == self.codeLength {
                    self.onCompletedInput?(code)
                }
            }
        }
    }

    // MARK: - Private
    private func setupTextField(_ textField: UITextField) {
        textField.keyboardType = .numberPad
        textField.font = AppStyle.Font.medium(24)
        textField.textAlignment = .center
        textField.contentVerticalAlignment = .center
        textField.returnKeyType = .next
        textField.delegate = self
        textField.addTarget(self,
                            action: #selector(textFieldDidChange(_:)),
                            for: .editingChanged)
    }
}

extension CodeInputTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = textField.text,
            let textRange = Range(range, in: text) else {
                return true
        }

        let updatedText = text
            .replacingCharacters(in: textRange, with: string)
            .replacingOccurrences(of: self.stubString, with: String())

        return updatedText.count <= 1
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == textField1 {
            // on start editing first TextField must be empty with nil
            // to enable autocompleete from SMS
            textField.text = nil
        } else {
            // on start editing first TextField must be empty with a stub string
            // to enable moving between TextFields backward on backspace
            textField.text = self.stubString
        }
        return true
    }
}

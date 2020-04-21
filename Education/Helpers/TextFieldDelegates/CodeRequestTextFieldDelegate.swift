//
//  CodeRequestTextFieldDelegate.swift
//  Education
//
//  Created by Andrey Medvedev on 14/09/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit
import InputMask

class CodeRequestTextFieldDelegate: MaskedTextFieldDelegate {
    var onCheckCountryCode: (() -> String?)?

    override func textField(_ textField: UITextField,
                            shouldChangeCharactersIn range: NSRange,
                            replacementString string: String) -> Bool {
        let checking = CharacterSet.whitespacesAndNewlines.inverted
        guard string.rangeOfCharacter(from: checking) != nil else {
            return true
        }

        var countryCodeLength = Int.zero
        if let countryCode = self.onCheckCountryCode?(),
            countryCode == String(string.prefix(countryCode.count)) {
            countryCodeLength = countryCode.count
        }

        let modifiedString = String(string.dropFirst(countryCodeLength))
        return super.textField(textField,
                               shouldChangeCharactersIn: range,
                               replacementString: modifiedString)
    }
}

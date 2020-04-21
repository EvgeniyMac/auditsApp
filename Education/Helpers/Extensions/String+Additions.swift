//
//  String+Additions.swift
//  Education
//
//  Created by Andrey Medvedev on 14/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

extension String {
    func toBool() -> Bool? {
        if let valueInt = Int(self) {
            return Bool(truncating: valueInt as NSNumber)
        }
        return nil
    }
}

extension String {
    func attributed(textColor: UIColor) -> NSAttributedString {
        return NSAttributedString(string: self,
                                  attributes: [.foregroundColor : textColor])
    }

    func attributed(with attributes: [NSAttributedString.Key: Any]?) -> NSAttributedString {
        return NSAttributedString(string: self, attributes: attributes)
    }
}

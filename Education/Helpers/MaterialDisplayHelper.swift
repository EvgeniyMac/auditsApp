//
//  MaterialDisplayHelper.swift
//  Education
//
//  Created by Andrey Medvedev on 04/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class MaterialDisplayHelper {

    static func getTypeImage(for material: Material?) -> UIImage? {
        guard let material = material,
            let type = material.documentType else {
            return nil
        }

        return getMaterialTypeImage(type: type,
                                    isActive: material.isActive ?? false)
    }

    static func getTitleText(for material: Material?) -> NSAttributedString? {
        let isFinished = material?.isFinished ?? false
        let font = isFinished ? AppStyle.Font.regular(16) : AppStyle.Font.medium(16)
        let isActive = material?.isActive ?? true
        let color = isActive ? AppStyle.Color.textSelected : AppStyle.Color.textDeselected
        let style = AppStyle.stringAttributes(font: font,
                                              color: color,
                                              underlined: false,
                                              alignment: .natural)
        let name = NSAttributedString(string: material?.name ?? String(),
                                      attributes: style)

        switch material?.documentType ?? .chapter {
        case .chapter:
            return name
        case .test, .exam:
            let result = NSMutableAttributedString(attributedString: name)
            if let questionsCount = material?.questionsCount {
                let questionsAmount = Localization.string(format: "plurable.questions.IP",
                                                          args: questionsCount)
                let questionsString = "\n\(questionsAmount)"

                let subtitleFont = AppStyle.Font.regular(16)
                let subtitleStyle = AppStyle.stringAttributes(font: subtitleFont,
                                                              color: color,
                                                              underlined: false,
                                                              alignment: .natural)
                result.append(NSAttributedString(string: questionsString,
                                                 attributes: subtitleStyle))
            }
            return result
        }
    }

    static func getDurationText(for material: Material?) -> String? {
        guard let timeoutInt = material?.timeout,
            let timeoutDouble = Double(exactly: timeoutInt) else {
                return nil
        }

        let measure = Localization.string("common.minutes_short")
        let value = Int(ceil(timeoutDouble / 60.0))
        return String(format: "%d \(measure)", value)
    }

    // MARK: - Private
    private static func getMaterialTypeImage(type: Material.DocumentType,
                                             isActive: Bool) -> UIImage? {
        switch type {
        case .chapter:
            if isActive {
                return UIImage(named: "material_type.text.available")
            } else {
                return UIImage(named: "material_type.text.unavailable")
            }
        case .test, .exam:
            if isActive {
                return UIImage(named: "material_type.test.available")
            } else {
                return UIImage(named: "material_type.test.unavailable")
            }
        }
    }
}

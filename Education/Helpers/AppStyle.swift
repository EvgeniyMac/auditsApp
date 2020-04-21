//
//  AppStyle.swift
//  Education
//
//  Created by Andrey Medvedev on 15/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class AppStyle {

    struct Text {
        static var courseTitleDefault: [NSAttributedString.Key: Any] {
            var attributes = AppStyle.stringAttributes(font: AppStyle.Font.medium(18),
                                                       color: AppStyle.Color.textMain,
                                                       underlined: false,
                                                       alignment: .natural)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 0
            paragraphStyle.lineHeightMultiple = 0.9
            attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
            return attributes
        }

        static var subtitleDefault: [NSAttributedString.Key: Any] {
            return AppStyle.stringAttributes(font: AppStyle.Font.regular(16),
                                             color: AppStyle.Color.textSupplementary,
                                             underlined: false,
                                             alignment: .center)
        }

        static var subtitleAction: [NSAttributedString.Key: Any] {
            return AppStyle.stringAttributes(font: AppStyle.Font.regular(16),
                                             color: AppStyle.Color.textAction,
                                             underlined: false,
                                             alignment: .center)
        }

        static var subtitleDisabled: [NSAttributedString.Key: Any] {
            return AppStyle.stringAttributes(font: AppStyle.Font.regular(16),
                                             color: AppStyle.Color.textDisabled,
                                             underlined: false,
                                             alignment: .center)
        }

        static var segmentDefault: [NSAttributedString.Key: Any] {
            return AppStyle.stringAttributes(font: AppStyle.Font.medium(18),
                                             color: AppStyle.Color.textDeselected,
                                             underlined: false,
                                             alignment: .center)
        }

        static var segmentSelected: [NSAttributedString.Key: Any] {
            return AppStyle.stringAttributes(font: AppStyle.Font.medium(18),
                                             color: AppStyle.Color.textSelected,
                                             underlined: false,
                                             alignment: .center)
        }

        static var largeTitleDefault: [NSAttributedString.Key: Any] {
            var attributes = AppStyle.stringAttributes(font: AppStyle.Font.semibold(24),
                                                       color: AppStyle.Color.textMain,
                                                       underlined: false,
                                                       alignment: .natural)

            let style = NSMutableParagraphStyle()
            style.alignment = .justified
            style.firstLineHeadIndent = .zero
            attributes[.paragraphStyle] = style

            return attributes
        }
    }

    struct Color {
        // Main colors
        static let green = custom(hex: 0x22A45D)
        static let blue = custom(hex: 0x266C92)
        static let orange = custom(hex: 0xE89539)
        static let red = custom(hex: 0xE85932)
        static let purple = custom(hex: 0x894BA7)

        // Black / white / gray colors
        static let white = custom(hex: 0xFFFFFF)
        static let darkGray = custom(hex: 0x757575)
        static let gray = custom(hex: 0x989898)
        static let lightGray = custom(hex: 0xE4E4E4)
        static let black = custom(hex: 0x010F07)
        static let blackBrightened = custom(hex: 0x444E48)

        // Others
        static let main = AppStyle.Color.green
        static let secondary = AppStyle.Color.white
        static let supplementary = custom(hex: 0x979797)

        static let backgroundMain = AppStyle.Color.white
        static let backgroundSecondary = custom(hex: 0xF1F1F1)
        static let backgroundSupplementary = custom(hex: 0xEBEBEB)
        static let backgroundCorrect = custom(hex: 0xDBFAEA)
        static let backgroundIncorrect = custom(hex: 0xFBE0D8)

        static let navigationBarBackground = UIColor.clear
        static let navigationBarTint = AppStyle.Color.black

        static let segmentedControlTint = AppStyle.Color.green

        // Text colors
        static let textMain = AppStyle.Color.black
        static let textMainBrightened = AppStyle.Color.custom(hex: 0x414141)
        static let textSecondary = custom(hex: 0x9A9A9A)
        static let textSupplementary = custom(hex: 0x868686)
        static let textAction = custom(hex: 0x22A45D)
        static let textDisabled = AppStyle.Color.gray
        static let textSelected = AppStyle.Color.custom(hex: 0x1C1C1C)
        static let textDeselected = AppStyle.Color.custom(hex: 0xC4C4C4)

        // Buttons colors
        static let buttonMain = AppStyle.Color.green
        static let buttonSecondary = AppStyle.Color.black
        static let buttonSupplementary = AppStyle.Color.white
        static let buttonDisabled = custom(hex: 0x979797)

        // Audit colors
        static let auditAccept = AppStyle.Color.green
        static let auditReject = AppStyle.Color.red
        static let auditRework = AppStyle.Color.orange

        static let optionMain = custom(hex: 0xF9E2C6)
        static let optionSecondary = custom(hex: 0xEEEEEE)

        static let warning = custom(hex: 0xD32F2F)
        static let success = custom(hex: 0x098838)
        static let failure = custom(hex: 0xD0021B)

        static let markerHighlight = custom(hex: 0xB0F0CA)
        static let markerDefault = custom(hex: 0xEAEAEA)

        static let avatarBackground = custom(hex: 0xD8D8D8)
        static let avatarText = custom(hex: 0x7E7E7E)
        static let separator = custom(hex: 0xC4C4C4)

        static let buttonTrue = custom(hex: 0x009245)
        static let buttonFalse = custom(hex: 0xD32F2F)

        static let borderColor = custom(hex: 0xD6D6D6)

        static let tintUnselected = custom(hex: 0x868686)

        static let shadowMain = AppStyle.Color.textMain

        static func custom(hex: Int, alpha: CGFloat = 1.0) -> UIColor {
            return UIColor(red: (hex >> 16) & 0xFF,
                           green: (hex >> 8) & 0xFF,
                           blue: hex & 0xFF,
                           alpha: alpha)
        }
    }

    struct Font {
        private static let lightName = "SFProDisplay-Light"
        private static let regularName = "SFProDisplay-Regular"
        private static let mediumName = "SFProDisplay-Medium"
        private static let semiboldName = "SFProDisplay-Semibold"
        private static let boldName = "SFProDisplay-Bold"

        static func light(_ size: CGFloat) -> UIFont {
            return UIFont(name: self.lightName, size: size)
                ?? UIFont.systemFont(ofSize: size,
                                     weight: UIFont.Weight.light)
        }

        static func regular(_ size: CGFloat) -> UIFont {
            return UIFont(name: self.regularName, size: size)
                ?? UIFont.systemFont(ofSize: size,
                                     weight: UIFont.Weight.regular)
        }

        static func medium(_ size: CGFloat) -> UIFont {
            return UIFont(name: self.mediumName, size: size)
                ?? UIFont.systemFont(ofSize: size,
                                     weight: UIFont.Weight.medium)
        }

        static func semibold(_ size: CGFloat) -> UIFont {
            return UIFont(name: self.semiboldName, size: size)
                ?? UIFont.systemFont(ofSize: size,
                                     weight: UIFont.Weight.semibold)
        }

        static func bold(_ size: CGFloat) -> UIFont {
            return UIFont(name: self.boldName, size: size)
                ?? UIFont.systemFont(ofSize: size,
                                     weight: UIFont.Weight.bold)
        }
    }

    struct CornerRadius {
        static let `default` = CGFloat(8)
        static let button = CGFloat(8)
        static let textCell = CGFloat(8)
        static let tile = CGFloat(10)
        static let label = CGFloat(4)
        static let tag = CGFloat(6)
        static let none = CGFloat(0)
    }

    struct Collection {
        struct Texts {
            static let itemHeight: CGFloat = 30
            static let interitemSpacing: CGFloat = 12
            static let lineSpacing: CGFloat = 12
            static let sectionInset = UIEdgeInsets(top: 20,
                                                   left: 20,
                                                   bottom: 20,
                                                   right: 20)
        }

        struct Tiles {
            static let itemHeight: CGFloat = 30
            static let interitemSpacing: CGFloat = 16
            static let lineSpacing: CGFloat = 16
            static let sectionInset = UIEdgeInsets(top: 20,
                                                   left: 20,
                                                   bottom: 20,
                                                   right: 20)
        }
    }

    struct Table {
        static let rowHeightDefault = CGFloat(50)
        static let segmentedHeaderHeight = CGFloat(54)
        static let separatorInsets = UIEdgeInsets(top: 0,
                                                  left: 20,
                                                  bottom: 0,
                                                  right: 20)
    }

    struct NavigationBar {
        static let buttonSize = CGSize(width: 32, height: 32)
        static let layoutMargins = UIEdgeInsets(top: 0,
                                                left: 20,
                                                bottom: 0,
                                                right: 8)
    }

    struct Alpha {
        static let `default` = CGFloat(1.0)
        static let disabled = CGFloat(0.5)
        static let hidden = CGFloat(0.0)
    }

    struct Border {
        static let button = CGFloat(2)
        static let selection = CGFloat(2)
        static let tile = CGFloat(2)
        static let tileSelection = CGFloat(4)
        static let photoSelection = CGFloat(3)
        static let `default` = CGFloat(1)
        static let label = CGFloat(1)
        static let none = CGFloat(0)
    }

    struct Image {
        static var answerCorrect: UIImage? {
            return UIImage(named: "state_completed_icon")
        }

        static var answerIncorrect: UIImage? {
            return UIImage(named: "state_failed_icon")
        }
    }

    struct Inset {
        static let buttonDefault = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        static let buttonConformityOption = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    }

    struct Gestures {
        static let dragDuration: TimeInterval = 0.1
    }

    // MARK: - Methods
    static func stringAttributes(font: UIFont,
                                 color: UIColor,
                                 underlined: Bool,
                                 alignment: NSTextAlignment) -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[NSAttributedString.Key.font] = font
        attributes[NSAttributedString.Key.foregroundColor] = color
        if underlined {
            attributes[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
        }

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = alignment
        attributes[NSAttributedString.Key.paragraphStyle] = paragraph

        return attributes
    }

    static func stringAttributes(font: UIFont,
                                 color: UIColor,
                                 lineSpacing: CGFloat) -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[NSAttributedString.Key.font] = font
        attributes[NSAttributedString.Key.foregroundColor] = color

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = lineSpacing
        paragraph.paragraphSpacing = lineSpacing
        attributes[NSAttributedString.Key.paragraphStyle] = paragraph

        return attributes
    }

    static func setupShadow(forContainer: UIView) {
        forContainer.layer.shadowRadius = 4
        forContainer.layer.shadowOpacity = 1
        forContainer.layer.shadowOffset = CGSize(width: 0, height: -2)
        let shadowColor = AppStyle.Color.custom(hex: 0x000000).withAlphaComponent(0.04)
        forContainer.layer.shadowColor = shadowColor.cgColor
    }
}

//
//  Localization.swift
//  Education
//
//  Created by Andrey Medvedev on 15/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

class Localization {
    enum Language: String, CaseIterable {
        case ru
        case en

        var resource: String {
            switch self {
            case .ru:
                return "ru"
            case .en:
                return "Base"
            }
        }

        var locale: Locale {
            switch self {
            case .ru:
                return Locale(identifier: "ru_RU")
            case .en:
                return Locale(identifier: "en_US_POSIX")
            }
        }

        var title: String {
            switch self {
            case .ru:
                return Localization.string("language.title.ru")
            case .en:
                return Localization.string("language.title.en")
            }
        }

        var valueShort: String {
            switch self {
            case .ru:
                return "ru"
            case .en:
                return "en"
            }
        }
    }

    private static let kLanguageKey = "kLanguageKey"

    static var language: Language {
        set {
            var shouldUpdate = true
            if let string = UserDefaults.standard.string(forKey: kLanguageKey),
                Language.init(rawValue: string) == newValue {
                shouldUpdate = false
            }

            if shouldUpdate {
                UserDefaults.standard.set(newValue.rawValue, forKey: kLanguageKey)
                UserDefaults.standard.synchronize()
                NotificationCenter.default.post(name: .DidChangeLanguage,
                                                object: nil)
            }
        }

        get {
            if let string = UserDefaults.standard.string(forKey: kLanguageKey),
                let languageValue = Language.init(rawValue: string) {
                return languageValue
            }

            // default language
            return .ru
        }
    }

    static func string(_ key: String) -> String {
        let resource = Localization.language.resource
        guard let path = Bundle.main.path(forResource: resource, ofType: "lproj"),
            let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: String())
        }

        return NSLocalizedString(key,
                                 tableName: nil,
                                 bundle: bundle,
                                 value: key,
                                 comment: String())
    }

    static func string(format: String, args: CVarArg...) -> String {
        let resource = Localization.language.resource
        guard let path = Bundle.main.path(forResource: resource, ofType: "lproj"),
            let bundle = Bundle(path: path) else {
                let localizedFormat = NSLocalizedString(format, comment: String())
                return withVaList(args, { (params) -> String in
                    return NSString(format: localizedFormat, arguments: params) as String
                })
        }

        let localizedFormat = NSLocalizedString(format,
                                                tableName: nil,
                                                bundle: bundle,
                                                value: format,
                                                comment: String())
        return withVaList(args, { (params) -> String in
            return NSString(format: localizedFormat, arguments: params) as String
        })
    }
}

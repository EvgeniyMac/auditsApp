//
//  CommonValue.swift
//  Education
//
//  Created by Andrey Medvedev on 07/08/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

struct CommonValue {
    static var appType: String {
        return "iOS/\(UIDevice.current.systemVersion)"
    }

    static var appVersion: String {
        let value = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        if let version = value as? String {
            return version
        }
        return String()
    }

    static var appLang: String {
        return Localization.language.valueShort
    }
}

//
//  Constants.swift
//  Education
//
//  Created by Andrey Medvedev on 15/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

#if DEBUG
let isDebug: Bool = true
#else
let isDebug: Bool = false
#endif

class Constants {

    #if DEBUG
    static let serverUrlDefault = URL(string: "https://api.dev.7skills.com")
    #else
    static let serverUrlDefault = URL(string: "https://api.7skills.com")
    #endif

    static let appStoreAppID = "id1465980133"
    static let appStoreUrl = URL(string: "itms-apps://itunes.apple.com/app/\(appStoreAppID)")

    static let sentryDSN = "https://4de872926ce841a595e91813f0d683a6@sentry.7skills.com/11"

    static let countryCodeDefault = "RU"

    static let courseWarningDaysNumber: Int = 4

    static let imageUploadMaxSide: CGFloat = 1000

    static let logoViewHeight: CGFloat = {
        let type = UIDevice().screenType
        switch type {
        case .iPhones_4_4S,
             .iPhones_5_5s_5c_SE:
            return CGFloat(150)
        case .iPhones_6_6s_7_8:
            return CGFloat(160)
        case .iPhones_6Plus_6sPlus_7Plus_8Plus:
            return CGFloat(220)
        case .iPhones_X_XS:
            return CGFloat(200)
        case .iPhone_XR,
             .iPhone_XSMax:
            return CGFloat(250)
        case .unknown:
            return CGFloat(200)
        }
    }()
}

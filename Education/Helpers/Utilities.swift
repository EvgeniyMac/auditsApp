//
//  Utilities.swift
//  Education
//
//  Created by Andrey Medvedev on 22/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation
import UIKit
import CoreTelephony

// MARK: - Operators
infix operator ??=
func ??= <T>(left: inout T?, right: T?) {
    left = left ?? right
}

// MARK: - Utilities class
class Utilities {
    static func isoCountryCode() -> String? {
        let info = CTTelephonyNetworkInfo()

        var carrier: CTCarrier?
        if #available(iOS 13.0, *) {
            carrier = info.serviceSubscriberCellularProviders?.values.first
        } else {
            carrier = info.subscriberCellularProvider
        }

        return carrier?.isoCountryCode
    }

    static func openAppInAppStore() {
        if let url = Constants.appStoreUrl {
            openUrl(url: url)
        }
    }

    static func openUrl(url: URL) {
        let app = UIApplication.shared
        if app.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                app.open(url, options: [:], completionHandler: nil)
            } else {
                app.openURL(url)
            }
        }
    }

    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}

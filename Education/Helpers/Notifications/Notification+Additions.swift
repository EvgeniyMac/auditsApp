//
//  Notification+Additions.swift
//  Education
//
//  Created by Andrey Medvedev on 16/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let DidAuthorize = Notification.Name(rawValue: "DidAuthorize")
    static let DidUnauthorize = Notification.Name(rawValue: "DidUnauthorize")
    static let DidRefreshTokenSucceeded = Notification.Name(rawValue: "DidRefreshTokenSucceededNotification")
    static let DidRefreshTokenFailed = Notification.Name(rawValue: "DidRefreshTokenFailedNotification")

    static let DidChangeLanguage = Notification.Name(rawValue: "DidChangeLanguage")

    static let DidChangedCourseStatus = Notification.Name(rawValue: "DidChangedCourseStatus")

    static let DidReceivePushNotification = Notification.Name(rawValue: "DidReceivePushNotification")

    static let DidUpdateStats = Notification.Name(rawValue: "DidUpdateStats")

    static let DidPassTest = Notification.Name(rawValue: "DidPassTest")
}

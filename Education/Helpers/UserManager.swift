//
//  UserManager.swift
//  Education
//
//  Created by Andrey Medvedev on 16/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation
import FirebaseAuth

class UserManager {
    private static let kAuthDataKey = "kAuthDataKey"
    private static let kFCMTokenKey = "kFCMTokenKey"
    private static let kFCMTokenRegisteredKey = "kFCMTokenRegisteredKey"
    private static let kTokenExpirationTimeoutMin = TimeInterval(600)

    static var auth: AuthData? {
        set {
            let encoder = JSONEncoder()
            UserDefaults.standard.set(try? encoder.encode(newValue), forKey: kAuthDataKey)
            UserDefaults.standard.synchronize()
        }

        get {
            if let data = UserDefaults.standard.object(forKey: kAuthDataKey) as? Data {
                let decoder = JSONDecoder()
                return try? decoder.decode(AuthData.self, from: data)
            }
            return nil
        }
    }

    static var fcmToken: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: kFCMTokenKey)
            UserDefaults.standard.synchronize()
        }

        get {
            return UserDefaults.standard.string(forKey: kFCMTokenKey)
        }
    }

    static var fcmTokenRegistered: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: kFCMTokenRegisteredKey)
            UserDefaults.standard.synchronize()
        }

        get {
            return UserDefaults.standard.string(forKey: kFCMTokenRegisteredKey)
        }
    }

    static func isAuthenticated() -> Bool {
        return self.auth != nil
    }

    static func logout() {
        self.auth = nil
        try? Auth.auth().signOut()
        NotificationManager.unsubscribeFromPushNotifications()
        NotificationCenter.default.post(name: .DidUnauthorize, object: nil)
    }

    static func authHeaderValue() -> String? {
        guard let typeValue = self.auth?.tokenType,
            let tokenValue = self.auth?.accessToken else {
                return nil
        }
        return "\(typeValue) \(tokenValue)"
    }

    static func refreshTokenIfNeeded() {
        guard let expirationDate = self.auth?.expirationDate else {
                return
        }

        let tokenExpirationTimeout = expirationDate.timeIntervalSince(Date())
        if tokenExpirationTimeout < kTokenExpirationTimeoutMin {
            let successHandler: ((AuthData) -> Void) = { (authData) in
                UserManager.auth = authData
                NotificationCenter.default.post(name: .DidRefreshTokenSucceeded,
                                                object: nil)
            }
            let failureHandler: ((NetworkError) -> Void) = { (error) in
                switch error {
                case .unauthorized:
                    UserManager.auth = nil
                    NotificationCenter.default.post(name: .DidRefreshTokenFailed,
                                                    object: nil)
                default:
                    break
                }
            }

            UserManager.refreshToken(success: successHandler,
                                     failure: failureHandler)
        }
    }

    static func refreshToken(success: @escaping ((AuthData) -> Void),
                             failure: @escaping ((NetworkError) -> Void)) {
        guard let refreshToken = self.auth?.refreshToken else {
            failure(.unauthorized)
            return
        }
        AuthService.refreshToken(using: refreshToken,
                                 success: success,
                                 failure: failure)
    }
}

//
//  AuthService.swift
//  Education
//
//  Created by Andrey Medvedev on 16/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation
import Alamofire

class AuthService {
    enum AuthCall: URLRequestConvertible {
        case authUsingFirebaseToken(token: String)
        case requestAuthCode(phoneNumber: String)
        case requestAccessToken(phoneNumber: String, authCode: String)
        case refreshAccessToken(refreshToken: String)
        case logout

        private var method: HTTPMethod {
            switch self {
            case .authUsingFirebaseToken,
                 .requestAuthCode,
                 .requestAccessToken,
                 .refreshAccessToken:
                return .post
            case .logout:
                return .get
            }
        }

        private var path: String {
            switch self {
            case .authUsingFirebaseToken:
                return "v2/auth/login-by-token"
            case .requestAuthCode:
                return "v2/auth/auth-code"
            case .requestAccessToken:
                return "v2/auth/login"
            case .refreshAccessToken:
                return "v2/auth/refresh"
            case .logout:
                return "v2/auth/logout"
            }
        }

        private var encoding: ParameterEncoding {
            switch self {
            case .authUsingFirebaseToken,
                 .requestAuthCode,
                 .requestAccessToken,
                 .refreshAccessToken:
                return Alamofire.JSONEncoding.default
            case .logout:
                return Alamofire.URLEncoding.default
            }
        }

        func asURLRequest() throws -> URLRequest {
            let request = Networking.shared.request(path: path, method: method)
            var parameters = Parameters()

            switch self {
            case .authUsingFirebaseToken(let token):
                parameters["token"] = token
            case .requestAuthCode(let phoneNumber):
                parameters["phone"] = phoneNumber
            case .requestAccessToken(let phoneNumber, let authCode):
                parameters["phone"] = phoneNumber
                parameters["auth_code"] = authCode
            case .refreshAccessToken(let refreshToken):
                parameters["refresh_token"] = refreshToken
            case .logout:
                break
            }

            return try self.encoding.encode(request, with: parameters)
        }
    }

    static func authUsingFirebaseToken(token: String,
                                       success: @escaping (AuthData) -> Void,
                                       failure: @escaping (NetworkError) -> Void) {
        let serviceCall = AuthCall.authUsingFirebaseToken(token: token)
        Networking.auth.performRequestObject(call: serviceCall,
                                             success: success,
                                             failure: failure)
    }

    static func requestAuthCode(phoneNumber: String,
                                success: @escaping () -> Void,
                                failure: @escaping (NetworkError) -> Void) {
        let serviceCall = AuthCall.requestAuthCode(phoneNumber: phoneNumber)
        Networking.auth.performRequest(call: serviceCall,
                                       success: success,
                                       failure: failure)
    }

    static func requestAccessToken(phoneNumber: String,
                                   authCode: String,
                                   success: @escaping (AuthData) -> Void,
                                   failure: @escaping (NetworkError) -> Void) {
        let serviceCall = AuthCall.requestAccessToken(phoneNumber: phoneNumber,
                                                      authCode: authCode)
        Networking.auth.performRequestObject(call: serviceCall,
                                             success: success,
                                             failure: failure)
    }

    static func refreshToken(using refreshToken: String,
                             success: @escaping (AuthData) -> Void,
                             failure: @escaping (NetworkError) -> Void) {
        let serviceCall = AuthCall.refreshAccessToken(refreshToken: refreshToken)
        Networking.auth.performRequestObject(call: serviceCall,
                                             success: success,
                                             failure: failure)
    }

    static func logout(success: @escaping () -> Void,
                       failure: @escaping (NetworkError) -> Void) {
        Networking.shared.performRequest(call: AuthCall.logout,
                                         success: success,
                                         failure: failure)
    }
}

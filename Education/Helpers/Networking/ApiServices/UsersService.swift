//
//  UsersService.swift
//  Education
//
//  Created by Andrey Medvedev on 05/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation
import Alamofire

class UsersService {

    private static let kDataKeyPath: String? = "data"

    enum UsersCall: URLRequestConvertible {
        case getCurrentUser
        case sendUserTimeZone(timeZone: String)
        // TODO: API: POST /v2/users/current/logo (сохранить лого)

        private var method: HTTPMethod {
            switch self {
            case .getCurrentUser:
                return .get
            case .sendUserTimeZone:
                return .post
            }
        }

        private var path: String {
            switch self {
            case .getCurrentUser:
                return "v2/users/current"
            case .sendUserTimeZone:
                return "v2/users/current/timezone"
            }
        }

        private var encoding: ParameterEncoding {
            switch self {
            case .getCurrentUser:
                return Alamofire.URLEncoding.default
            case .sendUserTimeZone:
                return Alamofire.JSONEncoding.default
            }
        }

        func asURLRequest() throws -> URLRequest {
            let request = Networking.shared.request(path: path, method: method)
            var parameters = Parameters()
            switch self {
            case .sendUserTimeZone(let timeZone):
                parameters["time_zone"] = timeZone
            default:
                break
            }
            return try self.encoding.encode(request, with: parameters)
        }
    }

    static func getCurrentUser(success: @escaping (User) -> Void,
                               failure: @escaping (NetworkError) -> Void) {
        let serviceCall = UsersCall.getCurrentUser
        Networking.shared.performRequestObject(call: serviceCall,
                                               keyPath: kDataKeyPath,
                                               success: success,
                                               failure: failure)
    }

    static func sendUserTimeZone(timeZone: String,
                                 success: @escaping () -> Void,
                                 failure: @escaping (NetworkError) -> Void) {
        let serviceCall = UsersCall.sendUserTimeZone(timeZone: timeZone)
        Networking.shared.performRequest(call: serviceCall,
                                         success: success,
                                         failure: failure)
    }
}

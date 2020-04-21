//
//  NotificationsService.swift
//  Education
//
//  Created by Andrey Medvedev on 22/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation
import Alamofire

class NotificationsService {

    enum NotificationsCall: URLRequestConvertible {
        case saveDeviceToken(deviceToken: String)

        private var method: HTTPMethod {
            switch self {
            case .saveDeviceToken:
                return .put
            }
        }

        private var path: String {
            switch self {
            case .saveDeviceToken:
                return "v2/notifications/push/token"
            }
        }

        private var encoding: ParameterEncoding {
            switch self {
            case .saveDeviceToken:
                return Alamofire.JSONEncoding.default
            }
        }

        func asURLRequest() throws -> URLRequest {
            let request = Networking.shared.request(path: path, method: method)
            var parameters = Parameters()

            switch self {
            case .saveDeviceToken(let deviceToken):
                parameters["token"] = deviceToken
            }

            return try self.encoding.encode(request, with: parameters)
        }
    }

    static func saveDeviceToken(_ deviceToken: String,
                                success: @escaping () -> Void,
                                failure: @escaping (NetworkError) -> Void) {
        let serviceCall = NotificationsCall.saveDeviceToken(deviceToken: deviceToken)
        Networking.shared.performRequest(call: serviceCall,
                                         success: success,
                                         failure: failure)
    }
}

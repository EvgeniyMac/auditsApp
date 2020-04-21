//
//  ChatsService.swift
//  Education
//
//  Created by Andrey Medvedev on 24.12.2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Alamofire

class ChatsService {

    private static let kDataKeyPath: String? = "data"

    enum ChatsCall: URLRequestConvertible {
        case requestHelpChat(type: HelpChatType)

        private var method: HTTPMethod {
            switch self {
            case .requestHelpChat:
                return .post
            }
        }

        private var path: String {
            switch self {
            case .requestHelpChat:
                return "v2/talk/chat/help-channels"
            }
        }

        private var encoding: ParameterEncoding {
            switch self {
            case .requestHelpChat:
                return Alamofire.JSONEncoding.default
            }
        }

        func asURLRequest() throws -> URLRequest {
            let request = Networking.shared.request(path: path, method: method)
            var parameters = Parameters()
            switch self {
            case .requestHelpChat(let type):
                parameters["channel_type"] = type.rawValue
            }
            return try self.encoding.encode(request, with: parameters)
        }
    }

    static func requestHelpChat(type: HelpChatType,
                                success: @escaping (HelpChat) -> Void,
                                failure: @escaping (NetworkError) -> Void) {
        let serviceCall = ChatsCall.requestHelpChat(type: type)
        Networking.shared.performRequestObject(call: serviceCall,
                                               keyPath: kDataKeyPath,
                                               success: success,
                                               failure: failure)
    }
}

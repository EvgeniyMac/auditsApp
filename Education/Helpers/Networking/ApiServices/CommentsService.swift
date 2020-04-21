//
//  CommentsService.swift
//  Education
//
//  Created by Andrey Medvedev on 10.03.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import Alamofire

class CommentsService {

    private static let kDataKeyPath: String? = "data"

    enum CommentCall: URLRequestConvertible {
        case sendComment(comment: Comment)
        case getComments(objectId: String,
                        objectType: Comment.ObjectType,
                        questionId: String,
                        page: Int)

        private var method: HTTPMethod {
            switch self {
            case .sendComment:
                return .post
            case .getComments:
                return .get
            }
        }

        private var path: String {
            switch self {
            case .sendComment:
                return "v2/comments"
            case .getComments:
                return "v2/comments"
            }
        }

        private var encoding: ParameterEncoding {
            switch self {
            case .sendComment:
                return Alamofire.JSONEncoding.default
            case .getComments:
                return Alamofire.URLEncoding.default
            }
        }

        func asURLRequest() throws -> URLRequest {
            let request = Networking.shared.request(path: path, method: method)
            var parameters = Parameters()
            switch self {
            case .sendComment(let comment):
                parameters = comment.toJSON()
            case .getComments(let objectId, let objectType, let questionId, let page):
                parameters["object_id"] = objectId
                parameters["object_type"] = objectType.rawValue
                parameters["meta[question_id]"] = questionId
                parameters["page"] = page
            }
            return try self.encoding.encode(request, with: parameters)
        }
    }

    static func getAuditComments(objectId: String,
                                 questionId: String,
                                 page: Int,
                                 success: @escaping (CommentsBundle) -> Void,
                                 failure: @escaping (NetworkError) -> Void) {
        let serviceCall = CommentCall.getComments(objectId: objectId,
                                                  objectType: .answer,
                                                  questionId: questionId,
                                                  page: page)
        Networking.shared.performRequestObject(call: serviceCall,
                                               keyPath: nil,
                                               success: success,
                                               failure: failure)
    }

    static func sendComment(comment: Comment,
                            success: @escaping () -> Void,
                            failure: @escaping (NetworkError) -> Void) {
        let serviceCall = CommentCall.sendComment(comment: comment)
        Networking.shared.performRequest(call: serviceCall,
                                         success: success,
                                         failure: failure)
    }
}

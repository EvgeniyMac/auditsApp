//
//  NewsService.swift
//  Education
//
//  Created by Andrey Medvedev on 19.12.2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Alamofire

class NewsService {

    private static let kDataKeyPath: String? = "data"

    enum NewsCall: URLRequestConvertible {
        case getArticles(page: Int)
        case getArticle(articleId: String)

        private var method: HTTPMethod {
            switch self {
            case .getArticles,
                 .getArticle:
                return .get
            }
        }

        private var path: String {
            switch self {
            case .getArticles:
                return "v2/talk/articles"
            case .getArticle(let articleId):
                return "v2/talk/articles/\(articleId)"
            }
        }

        private var encoding: ParameterEncoding {
            switch self {
            case .getArticles,
                 .getArticle:
                return Alamofire.URLEncoding.default
            }
        }

        func asURLRequest() throws -> URLRequest {
            let request = Networking.shared.request(path: path, method: method)
            var parameters = Parameters()
            switch self {
            case .getArticles(let page):
                parameters["page"] = page
            default:
                break
            }
            return try self.encoding.encode(request, with: parameters)
        }
    }

    static func getArticles(page: Int,
                            success: @escaping (NewsBundle) -> Void,
                            failure: @escaping (NetworkError) -> Void) {
        let serviceCall = NewsCall.getArticles(page: page)
        Networking.shared.performRequestObject(call: serviceCall,
                                               keyPath: nil,
                                               success: success,
                                               failure: failure)
    }

    static func getArticle(articleId: String,
                           success: @escaping (NewsItem) -> Void,
                           failure: @escaping (NetworkError) -> Void) {
        let serviceCall = NewsCall.getArticle(articleId: articleId)
        Networking.shared.performRequestObject(call: serviceCall,
                                               keyPath: kDataKeyPath,
                                               success: success,
                                               failure: failure)
    }
}

//
//  FavoritesService.swift
//  Education
//
//  Created by Andrey Medvedev on 12/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Alamofire

class FavoritesService {

    private static let kDataKeyPath: String? = "data"

    enum FavoritesCall: URLRequestConvertible {
        case addToFavorites(courseId: String)
        case removeFromFavorites(courseId: String)

        private var method: HTTPMethod {
            switch self {
            case .addToFavorites:
                return .patch
            case .removeFromFavorites:
                return .delete
            }
        }

        private var path: String {
            switch self {
            case .addToFavorites(let courseId):
                return "v2/courses/\(courseId)/favorite"
            case .removeFromFavorites(let courseId):
                return "v2/courses/\(courseId)/favorite"
            }
        }

        private var encoding: ParameterEncoding {
            switch self {
            case .addToFavorites,
                 .removeFromFavorites:
                return Alamofire.URLEncoding.default
            }
        }

        func asURLRequest() throws -> URLRequest {
            let request = Networking.shared.request(path: path, method: method)
            let parameters = Parameters()
            return try self.encoding.encode(request, with: parameters)
        }
    }

    static func addCourseToFavorites(courseId: String,
                                     success: @escaping () -> Void,
                                     failure: @escaping (NetworkError) -> Void) {
        let serviceCall = FavoritesCall.addToFavorites(courseId: courseId)
        Networking.shared.performRequest(call: serviceCall,
//                                         keyPath: kDataKeyPath,
                                         success: success,
                                         failure: failure)
    }

    static func removeCourseFromFavorites(courseId: String,
                                          success: @escaping () -> Void,
                                          failure: @escaping (NetworkError) -> Void) {
        let serviceCall = FavoritesCall.removeFromFavorites(courseId: courseId)
        Networking.shared.performRequest(call: serviceCall,
//                                         keyPath: kDataKeyPath,
                                         success: success,
                                         failure: failure)
    }
}

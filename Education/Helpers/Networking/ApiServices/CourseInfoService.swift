//
//  CourseInfoService.swift
//  Education
//
//  Created by Andrey Medvedev on 24/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Alamofire

class CourseInfoService {

    private static let kDataKeyPath: String? = "data"

    enum CourseInfoCall: URLRequestConvertible {
        case getCourseReviews(courseId: String)

        private var method: HTTPMethod {
            switch self {
            case .getCourseReviews:
                return .get
            }
        }

        private var path: String {
            switch self {
            case .getCourseReviews(let courseId):
                return "v2/courses/reviews/\(courseId)"
            }
        }

        private var encoding: ParameterEncoding {
            switch self {
            case .getCourseReviews:
                return Alamofire.URLEncoding.default
            }
        }

        func asURLRequest() throws -> URLRequest {
            let request = Networking.shared.request(path: path, method: method)
            let parameters = Parameters()
            return try self.encoding.encode(request, with: parameters)
        }
    }

    static func getCourseReviews(courseId: String,
                                 success: @escaping ([CourseReview]) -> Void,
                                 failure: @escaping (NetworkError) -> Void) {
        let serviceCall = CourseInfoCall.getCourseReviews(courseId: courseId)
        Networking.shared.performRequestArray(call: serviceCall,
                                              keyPath: kDataKeyPath,
                                              success: success,
                                              failure: failure)
    }
}

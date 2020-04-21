//
//  CoursesService.swift
//  Education
//
//  Created by Andrey Medvedev on 18/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation
import Alamofire

class CoursesService {

    private static let kDataKeyPath: String? = "data"

    enum CoursesCall: URLRequestConvertible {
        case loadRecommendedAndMarketCourses
        case loadRecommendedCourses(page: Int, perPage: Int)
        case loadMineCourses(page: Int, perPage: Int)
        case loadMarketCourses(page: Int, perPage: Int)
        case loadFilteredCourses(filter: String, page: Int, perPage: Int)

        case loadCourse(courseId: String)

        // TODO: API: GET /v2/courses/reviews/5d886b8422615e0009734ad0 (отзывы назначения)
        case loadMaterial(materialId: String, courseId: String)
        case loadRandomCourses
        case loadMarketCourse(courseId: String)
        case activateCourse(courseId: String)

        private var method: HTTPMethod {
            switch self {
            case .loadRecommendedAndMarketCourses,
                 .loadRecommendedCourses,
                 .loadMineCourses,
                 .loadMarketCourses,
                 .loadFilteredCourses,
                 .loadCourse,
                 .loadMaterial,
                 .loadRandomCourses,
                 .loadMarketCourse:
                return .get
            case .activateCourse:
                return .post
            }
        }

        private var path: String {
            switch self {
            case .loadRecommendedAndMarketCourses:
                return "/v2/courses/recommended-market"
            case .loadRecommendedCourses:
                return "v2/courses/recommended"
            case .loadMineCourses:
                return "v2/courses/mine"
            case .loadMarketCourses:
                return "v2/courses/free-market"
            case .loadFilteredCourses:
                return "v2/courses/filtered"
            case .loadCourse(let courseId):
                return "v2/courses/\(courseId)"
            case .loadMaterial(let materialId, let courseId):
                return "v2/courses/\(courseId)/materials/\(materialId)"
            case .loadRandomCourses:
                return "v2/random-materials"
            case .loadMarketCourse(let courseId):
                return "v2/materials/\(courseId)"
            case .activateCourse:
                return "v2/assign-material-to-user"
            }
        }

        private var encoding: ParameterEncoding {
            switch self {
            case .loadRecommendedAndMarketCourses,
                 .loadRecommendedCourses,
                 .loadMineCourses,
                 .loadMarketCourses,
                 .loadFilteredCourses,
                 .loadCourse,
                 .loadMaterial,
                 .loadRandomCourses,
                 .loadMarketCourse:
                return Alamofire.URLEncoding.default
            case .activateCourse:
                return Alamofire.JSONEncoding.default
            }
        }

        func asURLRequest() throws -> URLRequest {
            let request = Networking.shared.request(path: path, method: method)
            var parameters = Parameters()
            switch self {
            case .activateCourse(let courseId):
                parameters["material_id"] = courseId
            case .loadRecommendedCourses(let page, let perPage),
                 .loadMineCourses(let page, let perPage),
                 .loadMarketCourses(let page, let perPage):
                parameters["page"] = page
                parameters["per_page"] = perPage
            case .loadFilteredCourses(let filter, let page, let perPage):
                parameters["search_string"] = filter
                parameters["page"] = page
                parameters["per_page"] = perPage
            default:
                break
            }
            return try self.encoding.encode(request, with: parameters)
        }
    }

    static func loadRecommendedAndMarketCourses(success: @escaping (CoursesBundle) -> Void,
                                                failure: @escaping (NetworkError) -> Void) {
        let serviceCall = CoursesCall.loadRecommendedAndMarketCourses
        Networking.shared.performRequestObject(call: serviceCall,
                                               keyPath: nil,
                                               success: success,
                                               failure: failure)
    }

    static func loadRecommendedCourses(page: Int,
                                       perPage: Int,
                                       success: @escaping (CoursesListPage) -> Void,
                                       failure: @escaping (NetworkError) -> Void) {
        let serviceCall = CoursesCall.loadRecommendedCourses(page: page, perPage: perPage)
        Networking.shared.performRequestObject(call: serviceCall,
                                               keyPath: nil,
                                               success: success,
                                               failure: failure)
    }

    static func loadMineCourses(page: Int,
                                perPage: Int,
                                success: @escaping (CoursesListPage) -> Void,
                                failure: @escaping (NetworkError) -> Void) {
        let serviceCall = CoursesCall.loadMineCourses(page: page, perPage: perPage)
        Networking.shared.performRequestObject(call: serviceCall,
                                               keyPath: nil,
                                               success: success,
                                               failure: failure)
    }

    static func loadMarketCourses(page: Int,
                                  perPage: Int,
                                  success: @escaping (CoursesListPage) -> Void,
                                  failure: @escaping (NetworkError) -> Void) {
        let serviceCall = CoursesCall.loadMarketCourses(page: page, perPage: perPage)
        Networking.shared.performRequestObject(call: serviceCall,
                                               keyPath: nil,
                                               success: success,
                                               failure: failure)
    }

    static func loadRandomCourses(success: @escaping ([Course]) -> Void,
                                  failure: @escaping (NetworkError) -> Void) {
        let serviceCall = CoursesCall.loadRandomCourses
        Networking.shared.performRequestArray(call: serviceCall,
                                              keyPath: kDataKeyPath,
                                              success: success,
                                              failure: failure)
    }

    static func loadFilteredCourses(filter: String,
                                    page: Int,
                                    perPage: Int,
                                    success: @escaping (CoursesListPage) -> Void,
                                    failure: @escaping (NetworkError) -> Void) {
        let serviceCall = CoursesCall.loadFilteredCourses(filter: filter,
                                                          page: page,
                                                          perPage: perPage)
        Networking.shared.performRequestObject(call: serviceCall,
                                               keyPath: nil,
                                               success: success,
                                               failure: failure)
    }

    static func loadRecommendedCourses(success: @escaping (CoursesListPage) -> Void,
                                       failure: @escaping (NetworkError) -> Void) {
        let serviceCall = CoursesCall.loadRecommendedCourses(page: 1, perPage: 100)
        Networking.shared.performRequestObject(call: serviceCall,
                                               success: success,
                                               failure: failure)
    }

    static func loadMarketCourses(success: @escaping (CoursesListPage) -> Void,
                                  failure: @escaping (NetworkError) -> Void) {
        let serviceCall = CoursesCall.loadMarketCourses(page: 1, perPage: 100)
        Networking.shared.performRequestObject(call: serviceCall,
                                               success: success,
                                               failure: failure)
    }

    static func loadMarketCourse(courseId: String,
                                 success: @escaping (Course) -> Void,
                                 failure: @escaping (NetworkError) -> Void) {
        let serviceCall = CoursesCall.loadMarketCourse(courseId: courseId)
        Networking.shared.performRequestObject(call: serviceCall,
                                               keyPath: kDataKeyPath,
                                               success: success,
                                               failure: failure)
    }

    static func loadCourse(courseId: String,
                           success: @escaping (Course) -> Void,
                           failure: @escaping (NetworkError) -> Void) {
        let serviceCall = CoursesCall.loadCourse(courseId: courseId)
        Networking.shared.performRequestObject(call: serviceCall,
                                               keyPath: kDataKeyPath,
                                               success: success,
                                               failure: failure)
    }

    static func loadMaterial(materialId: String,
                             courseId: String,
                             success: @escaping (Material) -> Void,
                             failure: @escaping (NetworkError) -> Void) {
        let serviceCall = CoursesCall.loadMaterial(materialId: materialId,
                                                   courseId: courseId)
        Networking.shared.performRequestObject(call: serviceCall,
                                               keyPath: kDataKeyPath,
                                               success: success,
                                               failure: failure)
    }

    static func activateCourse(courseId: String,
                               success: @escaping (Course) -> Void,
                               failure: @escaping (NetworkError) -> Void) {
        let serviceCall = CoursesCall.activateCourse(courseId: courseId)
        Networking.shared.performRequestObject(call: serviceCall,
                                               success: success,
                                               failure: failure)
    }
}

//
//  MaterialsService.swift
//  Education
//
//  Created by Andrey Medvedev on 06/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation
import Alamofire

class MaterialsService {

    private static let kDataKeyPath: String? = "data"

    enum MaterialsCall: URLRequestConvertible {
        case markLessonAsPassed(appointmentId: String, materialId: String)
        case saveAnswers(appointmentId: String, materialId: String, items: [Questionnaire.Item])
        case reportLessonSpentTime(appointmentId: String, lessonId: String, timeSpent: Int)

        private var method: HTTPMethod {
            switch self {
            case .markLessonAsPassed,
                 .saveAnswers:
                return .post
            case .reportLessonSpentTime:
                return .put
            }
        }

        private var path: String {
            switch self {
            case .markLessonAsPassed:
                return "v2/lesson/stage"
            case .saveAnswers:
                return "v2/answers"
            case .reportLessonSpentTime:
                return "v2/lesson/time-spent"
            }
        }

        private var encoding: ParameterEncoding {
            return Alamofire.JSONEncoding.default
        }

        func asURLRequest() throws -> URLRequest {
            let request = Networking.shared.request(path: path, method: method)
            var parameters = Parameters()

            switch self {
            case .markLessonAsPassed(let appointmentId, let materialId):
                parameters["appointment_id"] = appointmentId
                parameters["lesson_id"] = materialId
            case .saveAnswers(let appointmentId, let materialId, let items):
                parameters["appointment_id"] = appointmentId
                parameters["test_material_id"] = materialId
                let answersJSON = items.compactMap({ (item) -> [String : Any]? in
                    let value = item.toJSON()
                    return !value.isEmpty ? value : nil
                })
                parameters["answers"] = !answersJSON.isEmpty ? answersJSON : nil
            case .reportLessonSpentTime(let appointmentId, let lessonId, let timeSpent):
                parameters["appointment_id"] = appointmentId
                parameters["lesson_id"] = lessonId
                parameters["time_spent"] = timeSpent
            }

            return try self.encoding.encode(request, with: parameters)
        }
    }

    static func markLessonAsPassed(courseId: String,
                                   materialId: String,
                                   success: @escaping (Material) -> Void,
                                   failure: @escaping (NetworkError) -> Void) {
        let serviceCall = MaterialsCall.markLessonAsPassed(appointmentId: courseId,
                                                           materialId: materialId)
        Networking.shared.performRequestObject(call: serviceCall,
                                               keyPath: kDataKeyPath,
                                               success: success,
                                               failure: failure)
    }

    static func saveAnswers(questionnaire: Questionnaire,
                            success: @escaping (CourseResult) -> Void,
                            failure: @escaping (NetworkError) -> Void) {
        guard let courseId = questionnaire.course.identifier,
            let materialId = questionnaire.material.identifier else {
                failure(NetworkError.insufficientRequestData)
                return
        }

        let serviceCall = MaterialsCall.saveAnswers(appointmentId: courseId,
                                                    materialId: materialId,
                                                    items: questionnaire.questionItems)
        Networking.shared.performRequestObject(call: serviceCall,
                                               keyPath: nil,
                                               success: success,
                                               failure: failure)
    }

    static func reportLessonSpentTime(courseId: String,
                                      materialId: String,
                                      spentTime: Int,
                                      success: @escaping () -> Void,
                                      failure: @escaping (NetworkError) -> Void) {
        let serviceCall = MaterialsCall.reportLessonSpentTime(appointmentId: courseId,
                                                              lessonId: materialId,
                                                              timeSpent: spentTime)
        Networking.shared.performRequest(call: serviceCall,
                                         success: success,
                                         failure: failure)
    }
}

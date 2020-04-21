//
//  AuditService.swift
//  Education
//
//  Created by Andrey Medvedev on 19.02.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import Alamofire

class AuditService {

    private static let kDataKeyPath: String? = "data"

    enum AuditCall: URLRequestConvertible {
        case getAudits(page: Int, filter: AuditFilter)
        case getAudit(auditId: String)
        case sendAnswers(answers: [AuditAnswer], auditId: String, libraryId: String)
        case changeAuditStatus(auditId: String, status: Audit.Status, comment: String)
        case checkAudit(result: AuditCheck)

        private var method: HTTPMethod {
            switch self {
            case .getAudits:
                return .post
            case .getAudit:
                return .get
            case .sendAnswers:
                return .post
            case .changeAuditStatus:
                return .patch
            case .checkAudit:
                return .patch
            }
        }

        private var path: String {
            switch self {
            case .getAudits:
                return "v2/audits"
            case .getAudit(let auditId):
                return "v2/audits/\(auditId)"
            case .sendAnswers:
                return "v2/audits/answers"
            case .changeAuditStatus(let auditId, _, _):
                return "v2/audits/\(auditId)/status"
            case .checkAudit:
                return "v2/audits/answers"
            }
        }

        private var encoding: ParameterEncoding {
            switch self {
            case .getAudits:
                return Alamofire.JSONEncoding.default
            case .getAudit:
                return Alamofire.URLEncoding.default
            case .sendAnswers:
                return Alamofire.JSONEncoding.default
            case .changeAuditStatus:
                return Alamofire.JSONEncoding.default
            case .checkAudit:
                return Alamofire.JSONEncoding.default
            }
        }

        func asURLRequest() throws -> URLRequest {
            let request = Networking.shared.request(path: path, method: method)
            var parameters = Parameters()
            switch self {
            case .getAudits(let page, let filter):
                parameters["page"] = page
                parameters["division_ids"] = filter.divisionIds
                parameters["user_ids"] = filter.userIds
                parameters["time_start"] = filter.startDate
                parameters["time_end"] = filter.endDate
                parameters["statuses"] = filter.statuses
            case .sendAnswers(let answers, let auditId, let libraryId):
                parameters["audit_id"] = auditId
                parameters["library_id"] = libraryId
                let answersJSON = answers.compactMap({ (item) -> [String : Any]? in
                    let value = item.toJSON()
                    return !value.isEmpty ? value : nil
                })
                parameters["answers"] = !answersJSON.isEmpty ? answersJSON : nil
            case .changeAuditStatus(_, let status, let comment):
                parameters["status"] = status.rawValue
                parameters["comment"] = comment
            case .checkAudit(let result):
                parameters = result.toJSON()
            default:
                break
            }
            return try self.encoding.encode(request, with: parameters)
        }
    }

    static func getAudits(page: Int,
                          filter: AuditFilter,
                          success: @escaping (AuditsBundle) -> Void,
                          failure: @escaping (NetworkError) -> Void) {
        let serviceCall = AuditCall.getAudits(page: page, filter: filter)
        Networking.shared.performRequestObject(call: serviceCall,
                                               keyPath: nil,
                                               success: success,
                                               failure: failure)
    }

    static func getAudit(auditId: String,
                         success: @escaping (Audit) -> Void,
                         failure: @escaping (NetworkError) -> Void) {
        let serviceCall = AuditCall.getAudit(auditId: auditId)
        Networking.shared.performRequestObject(call: serviceCall,
                                               keyPath: kDataKeyPath,
                                               success: success,
                                               failure: failure)
    }

    static func sendAnswers(_ answers: [AuditAnswer],
                            auditId: String,
                            libraryId: String,
                            success: @escaping () -> Void,
                            failure: @escaping (NetworkError) -> Void) {
        let serviceCall = AuditCall.sendAnswers(answers: answers,
                                                auditId: auditId,
                                                libraryId: libraryId)
        Networking.shared.performRequest(call: serviceCall,
//                                         keyPath: kDataKeyPath,
                                         success: success,
                                         failure: failure)
    }

    static func changeStatus(auditId: String,
                             status: Audit.Status,
                             comment: String,
                             success: @escaping () -> Void,
                             failure: @escaping (NetworkError) -> Void) {
        let serviceCall = AuditCall.changeAuditStatus(auditId: auditId,
                                                      status: status,
                                                      comment: comment)
        Networking.shared.performRequest(call: serviceCall,
                                         success: success,
                                         failure: failure)
    }

    static func checkAudit(result: AuditCheck,
                           success: @escaping () -> Void,
                           failure: @escaping (NetworkError) -> Void) {
        let serviceCall = AuditCall.checkAudit(result: result)
        Networking.shared.performRequest(call: serviceCall,
                                         success: success,
                                         failure: failure)
    }

}

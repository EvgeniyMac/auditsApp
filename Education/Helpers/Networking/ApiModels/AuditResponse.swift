//
//  AuditResponse.swift
//  Education
//
//  Created by Andrey Medvedev on 24.03.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import ObjectMapper

struct AuditCheck: Mappable {

    struct AnswerCheck: Mappable {
        var questionId: String?
        var status: Audit.Status?

        init() {}

        // MARK: - Mappable
        init?(map: Map) { }

        func mapping(map: Map) {
            questionId >>> map["question_id"]
            status >>> (map["status"], EnumTransform<Audit.Status>())
        }
    }

    var auditId: String?
    var libraryId: String?
    var status: Audit.Status?
    var comment: String?
    var answers: [AuditCheck.AnswerCheck]?

    // MARK: - Mappable
    init?(map: Map) {
        auditId = try! map.value("audit_id")
        libraryId = try? map.value("library_id")
        status = try? map.value("status")
        comment = try? map.value("comment")
        answers = try? map.value("answers")
    }

    func mapping(map: Map) {
        auditId >>> map["audit_id"]
        libraryId >>> map["library_id"]
        status >>> (map["status"], EnumTransform<Audit.Status>())
        comment >>> map["comment"]
        answers >>> map["answers"]
    }
}

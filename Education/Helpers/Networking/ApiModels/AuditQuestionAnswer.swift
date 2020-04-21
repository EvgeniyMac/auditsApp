//
//  AuditQuestionAnswer.swift
//  Education
//
//  Created by Andrey Medvedev on 12.04.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import ObjectMapper

class AuditQuestionAnswer: Mappable {

    var answer: String?
    var status: Audit.Status?
    var responseTime: TimeInterval?
    var comments: [Comment]?
    var commentsMeta: BundleMeta?
    var media: AuditAnswer.Media?
    var questionId: String?
    var questionType: AuditQuestionType?

    required init?(map: Map) { }

    init() { }

    func mapping(map: Map) {
        answer <- map["answer"]
        status <- map["status"]
        responseTime <- map["response_time"]
        comments <- map["comments.data"]
        commentsMeta <- map["comments"]
        media <- map["media"]
        questionId <- map["question_id"]
        questionType <- map["type"]
    }
}

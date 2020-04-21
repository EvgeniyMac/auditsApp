//
//  AuditAnswer.swift
//  Education
//
//  Created by Andrey Medvedev on 02.03.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import ObjectMapper

struct AuditAnswer: Mappable {

    struct Media: Mappable {
        var photos = [URL]()

        init() {}

        // MARK: - Mappable
        init?(map: Map) { }

        func mapping(map: Map) {
            photos >>> (map["photos"], URLTransform())
        }
    }

    var questionId: String?
    var questionType: AuditQuestionType?
    var answer: String?
    var comment: String?
    var responseTime: TimeInterval?
    var media: AuditAnswer.Media

    init(question: AuditQuestion) {
        self.questionId = question.identifier
        self.questionType = question.questionType
        self.media = AuditAnswer.Media()
    }

    // MARK: - Mappable
    init?(map: Map) {
        questionId = try! map.value("question_id")
        questionType = try? map.value("type")
        answer = try? map.value("answer")
        comment = try? map.value("comment")
        responseTime = try? map.value("response_time")
        media = AuditAnswer.Media()
    }

    func mapping(map: Map) {
        questionId >>> map["question_id"]
        questionType >>> (map["type"], EnumTransform<AuditQuestionType>())
        answer >>> map["answer"]
        comment >>> map["comment"]
        responseTime >>> map["response_time"]
        media >>> map["media"]
    }
}

//
//  Material.swift
//  Education
//
//  Created by Andrey Medvedev on 23/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import ObjectMapper

class Material: Mappable {
    enum MaterialType: String {
        case test
        case lesson
        case document
    }

    enum DocumentType: String {
        case chapter = "document_chapter"
        case test = "document_test"
        case exam = "document_exam"
    }

    enum ShowCorrectType: String {
        case every
        case notShow = "not_show"
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()

    var identifier: String?
    var name: String?
    var type: MaterialType?
    var documentType: DocumentType?
    var timeout: Int?
    var courseId: String?
    var sort: Int?
    var contentHTML: String?
    var questions: [Question]?
    var isActive: Bool?
    var isPassed: Bool?
    var isFailed: Bool?

    var questionsCount: Int?
    var remainingAttemptsCount: Int?
    var showCorrect: ShowCorrectType?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        identifier <- map["id"]
        name <- map["name"]
        type <- map["type"]
        documentType <- map["document_type"]
        timeout <- map["timeout"]
        courseId <- map["appointmentId"]
        sort <- map["sort"]
        contentHTML <- map["content"]
        questions <- map["content"]
        isActive <- map["is_active"]
        isPassed <- map["is_passed"]
        isFailed <- map["is_failed"]

        questionsCount <- map["count_questions"]
        remainingAttemptsCount <- map["countRemainingAttempts"]
        showCorrect <- map["show_correct"]
    }
}

extension Material {
    func getDuration() -> TimeInterval? {
        if let value = self.timeout {
            return TimeInterval(value)
        } else if let questions = self.questions {
            var value: TimeInterval = 0
            for question in questions {
                value += question.duration
            }
            return value
        }
        return nil
    }

    var isFinished: Bool {
        return (self.isPassed == true) || (self.isFailed == true)
    }

    func getDescriptionInfo() -> String {
        var questionsString = String()
        if let questionsCount = self.questionsCount,
            let timeout = self.getDuration() {
            let questionsAmount = Localization.string(format: "plurable.questions.IP", args: questionsCount)
            let minutesAmount = Localization.string(format: "plurable.minutes.VP", args: Int(ceil(timeout / 60.0)))
            questionsString = Localization.string(format: "material.test_questions_format",
                                                  args: questionsAmount, minutesAmount)

//            let seconds = Int(timeout) % 60
//            if seconds > 0 {
//                let secondsAmount = Localization.string(format: "plurable.seconds.VP", args: seconds)
//                questionsString += " \(secondsAmount)"
//            }
        }

        return questionsString
    }
}

//
//  Question.swift
//  Education
//
//  Created by Andrey Medvedev on 25/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import ObjectMapper

class Question: Mappable {

    class UserAnswer {
        var value: Any?
        var valueArray = [String]()
        var valueDictionary = [String: String]()

        func isValid() -> Bool {
            return (value != nil)
            || !valueArray.isEmpty
            || !valueDictionary.isEmpty
        }
    }

    var identifier: String?
    var questionText: String?
    var type: QuestionType?
    var minutes: String?
    var seconds: String?
    var sort: String?
    var help: String?
    var explanation: String?
    var imageUrl: URL?
    var answers: [Answer]?
    var answerString: String?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        identifier <- map["id"]
        questionText <- map["text_question"]
        type <- map["type"]
        minutes <- map["minutes"]
        seconds <- map["seconds"]
        sort <- map["sort"]
        help <- map["help"]
        explanation <- map["explanation"]
        imageUrl <- (map["image_url"], URLTransform())
        answers <- map["answers"]
        if map.JSON["answers"] is String {
            answerString <- map["answers"]
        } else {
            answerString <- map["answers.true_answer"]
        }
    }
}

extension Question {
    var duration: TimeInterval {
        var value: TimeInterval = 0.0
        if let minutesString = self.minutes,
            let minutes = TimeInterval(minutesString) {
            value += minutes * 60.0
        }
        if let secondsString = self.seconds,
            let seconds = TimeInterval(secondsString) {
            value += seconds
        }
        return value
    }
}

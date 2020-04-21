//
//  CourseResult.swift
//  Education
//
//  Created by Andrey Medvedev on 12/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import ObjectMapper

class CourseResult: Mappable {
    enum Achievement: String {
        case first
    }

    var totalQuestions: Int?
    var rightAnswers: Int?
    var allowedErrors: Int?
    var achievement: Achievement?
    var ratingCurrentPlace: Int?
    var ratingTotalPlace: Int?
    var timeSpent: Int?
    var attemptsMade: Int?
    var isPassed: Bool?
    var sessionAnswerId: String?
    var forPasseAnswersCnt: Int?

    required init?(map: Map) { }

    func mapping(map: Map) {
        totalQuestions <- map["total_questions_cnt"]
        rightAnswers <- map["right_answers_cnt"]
        allowedErrors <- map["allowed_errors_cnt"]
        achievement <- map["reward_type"]
        ratingCurrentPlace <- map["current_place_rating"]
        ratingTotalPlace <- map["total_place_rating"]
        timeSpent <- map["time_spent"]
        attemptsMade <- map["count_make_attempts"]
        isPassed <- map["is_passed"]
        sessionAnswerId <- map["session_answer_id"]
        forPasseAnswersCnt <- map["for_passe_answers_cnt"]
    }
}

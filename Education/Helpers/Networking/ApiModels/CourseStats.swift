//
//  CourseStats.swift
//  Education
//
//  Created by Andrey Medvedev on 20/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import ObjectMapper

class CourseStats: Mappable {
    enum CourseStatus: String {
        case notStarted = "not_started"
        case watched
        case started
        case passed
        case failed
        case overdue //просрочен
        case overduePassed = "overdue_passed" //просрочен: пройден
        case overdueFailed = "overdue_failed" //просрочен: провален
    }

    enum StatusReason: String {
        case timeOver = "time_over"
        case attemptsEnded = "attempts_ended"
    }

    enum ExamState: String {
        case proceed
        case retake
        case passed
        case failed
    }

    var status: CourseStatus?
    var allMaterialsCount: Int?
    var passedMaterialsCount: Int?
    var usedAttemptsCount: Int?
    var reason: StatusReason?
    var examState: ExamState?
    var passedUsersCount: Int?

    required init?(map: Map) { }

    func mapping(map: Map) {
        status <- map["status"]
        reason <- map["status_reason"]
        allMaterialsCount <- map["count_all_materials"]
        passedMaterialsCount <- map["count_passed_materials"]
        usedAttemptsCount <- map["count_used_attempts"]
        examState <- map["exam_state"]
        passedUsersCount <- map["count_passed_user"]
    }
}

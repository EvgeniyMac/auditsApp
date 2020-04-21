//
//  LocalizedModels.swift
//  Education
//
//  Created by Andrey Medvedev on 03/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

protocol Localized {
    var localized: String { get }
}

extension CourseStats.StatusReason: Localized {
    var localized: String {
        switch self {
        case .timeOver:
            return Localization.string("course_stats.status_reason.time_over")
        case .attemptsEnded:
            return Localization.string("course_stats.status_reason.attempts_ended")
        }
    }
}

extension Course.CourseType: Localized {
    var localized: String {
        switch self {
        case .exam:
            return Localization.string("course.course_type.certification")
        case .course:
            return Localization.string("course.course_type.course")
        case .test:
            return Localization.string("course.course_type.test")
        }
    }
}

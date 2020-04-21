//
//  CourseDisplayHelper.swift
//  Education
//
//  Created by Andrey Medvedev on 02/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class CourseDisplayHelper {
    static func getComplexityText(for course: Course?) -> String? {
        guard let complexity = course?.complexity else {
            return nil
        }

        switch complexity {
        case .simple:
            return Localization.string("complexity.simple")
        case .middle:
            return Localization.string("complexity.difficult")
        case .hard:
            return Localization.string("complexity.pro")
        }
    }

    static func getComplexityImage(for course: Course?) -> UIImage? {
        guard let complexity = course?.complexity else {
            return nil
        }

        switch complexity {
        case .simple:
            return UIImage(named: "complexity_icon-easy")
        case .middle:
            return UIImage(named: "complexity_icon-normal")
        case .hard:
            return UIImage(named: "complexity_icon-hard")
        }
    }

    static func getDurationText(for course: Course?) -> String? {
        guard let timeoutInt = course?.timeout,
            let timeoutDouble = Double(exactly: timeoutInt) else {
            return nil
        }

        let measure = Localization.string("common.minutes_short")
        let value = Int(ceil(timeoutDouble / 60.0))
        return String(format: "%d \(measure)", value)
    }

    static func getCourseTypeText(for course: Course?) -> String? {
        guard let courseType = course?.type else {
            return nil
        }

        switch courseType {
        case .course:
            return Localization.string("course.course_type.course")
        case .exam:
            return Localization.string("course.course_type.certification")
        case .test:
            return Localization.string("course.course_type.test")
        }
    }

    static func getCourseTypeImage(for course: Course?) -> UIImage? {
        guard let courseType = course?.type else {
            return nil
        }

        switch courseType {
        case .course:
            return UIImage(named: "course_icon")
        case .exam:
            return UIImage(named: "exam.enabled")
        case .test:
            return UIImage(named: "test.enabled")
        }
    }

    static func getCourseRateText(for course: Course?) -> String? {
        guard let rate = course?.rate else {
            return nil
        }
        return String(format: "%.1f", rate)
    }

    static func getCoursePassedUsersText(for course: Course?) -> String? {
        guard let passedUsersCount = course?.stats?.passedUsersCount else {
            return nil
        }
        return String(passedUsersCount)
    }

    static func getMarkImage(for course: Course?) -> UIImage? {
        guard let mark = course?.mark else {
            return nil
        }

        switch mark {
        case .best:
            return UIImage(named: "mark_best_icon")
        case .discount:
            return UIImage(named: "mark_discount_icon")
        case .recommended:
            return UIImage(named: "mark_recommended_icon")
        }
    }

    static func getAgeRatingImage(for course: Course?) -> UIImage? {
        guard let ageRating = course?.ageRating else {
            return nil
        }

        switch ageRating {
        case .rating0:
            return UIImage(named: "pg0")
        case .rating6:
            return UIImage(named: "pg6")
        case .rating12:
            return UIImage(named: "pg12")
        case .rating16:
            return UIImage(named: "pg16")
        case .rating18:
            return UIImage(named: "pg18")
        }
    }
}

//
//  CourseStyle.swift
//  Education
//
//  Created by Andrey Medvedev on 08/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class CourseStyle {

    // MARK: - Texts
    static func getStatusText(forCourse: Course?) -> String? {
        var statusTitleKey: String?
        if let status = forCourse?.stats?.status {
            switch status {
            case .notStarted:
                statusTitleKey = "course.course.state.new"
            case .watched:
                statusTitleKey = "course.course.state.watched"
            case .started:
                statusTitleKey = "course.course.state.proceed"
            case .passed:
                statusTitleKey = "course.course.state.passed"
            case .failed:
                statusTitleKey = "course.course.state.failed"
            case .overdue:
                statusTitleKey = "course.course.state.overdue"
            case .overduePassed:
                statusTitleKey = "course.course.state.overdue_passed"
            case .overdueFailed:
                statusTitleKey = "course.course.state.overdue_failed"
            }
        }

        if let textKey = statusTitleKey {
            return Localization.string(textKey)
        }
        return nil
    }

    static func getStatusText(forExam: Course?) -> String? {
        var statusTitleKey: String?
        if let status = forExam?.stats?.status {
            switch status {
            case .notStarted:
                statusTitleKey = "course.exam.state.new"
            case .watched:
                statusTitleKey = "course.exam.state.watched"
            case .started:
                statusTitleKey = "course.exam.state.proceed"
            case .passed:
                statusTitleKey = "course.exam.state.passed"
            case .failed:
                statusTitleKey = "course.exam.state.failed"
            case .overdue:
                statusTitleKey = "course.exam.state.overdue"
            case .overduePassed:
                statusTitleKey = "course.exam.state.overdue_passed"
            case .overdueFailed:
                statusTitleKey = "course.exam.state.overdue_failed"
            }
        }

        if let textKey = statusTitleKey {
            return Localization.string(textKey)
        }
        return nil
    }

    // MARK: - Colors
    static func getStatusColor(for status: CourseStats.CourseStatus?) -> UIColor? {
        guard let status = status else {
            return nil
        }

        switch status {
        case .notStarted:
            return AppStyle.Color.green
        case .watched:
            // don't show status for "watched"
            return nil
        case .started:
            return AppStyle.Color.orange
        case .passed:
            return AppStyle.Color.gray
        case .failed:
            return AppStyle.Color.gray
        case .overdue, .overduePassed, .overdueFailed:
            return AppStyle.Color.gray
        }
    }
}

//
//  TableCellStyle.swift
//  Education
//
//  Created by Andrey Medvedev on 24/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class TableCellStyle {
    static func apply(to cell: CourseTableViewCell, course: Course?) {
        let titleAttributes = AppStyle.Text.courseTitleDefault
        let attributedTitle = course?.name?.attributed(with: titleAttributes)
        cell.titleLabel.attributedText = attributedTitle

        cell.typeLabel.text = CourseDisplayHelper.getCourseTypeText(for: course)
        cell.typeImageView.image = CourseDisplayHelper.getCourseTypeImage(for: course)

//        if let endDate = course?.endDate,
//            endDate.isInFuture(),
//            let daysLeft = endDate.daysSinceNow() {
//            cell.expirationView.isHidden = false
//
//            if daysLeft <= Constants.courseWarningDaysNumber {
//                cell.expirationImageView.image = UIImage(named: "expiration_icon-soon")
//                cell.expirationLabel.textColor = AppStyle.Color.warning
//
//                if daysLeft == 0 {
//                    let preposition = Localization.string(format: "common.preposition_today_at")
//                    cell.expirationLabel.text = endDate.dateTimeString(dateFormat: nil,
//                                                                       timeFormat: Date.timeFormatReadable,
//                                                                       locale: Localization.language.locale,
//                                                                       timePreposition: preposition)
//                } else if daysLeft == 1 {
//                    cell.expirationLabel.text = Localization.string(format: "common.tomorrow")
//                } else {
//                    cell.expirationLabel.text = Localization.string(format: "plurable.days_left_count", args: daysLeft)
//                }
//            } else {
//                cell.expirationImageView.image = UIImage(named: "expiration_icon-late")
//                cell.expirationLabel.textColor = AppStyle.Color.textMain
//                let weeksLeft = daysLeft / 7
//                cell.expirationLabel.text = Localization.string(format: "plurable.weeks_left_count", args: weeksLeft)
//            }
//        } else {
//            cell.expirationView.isHidden = true
//
//            cell.expirationImageView.image = nil
//            cell.expirationLabel.text = nil
//        }

        if let coverUrl = course?.coverUrl {
            cell.logoImageView.setImage(withUrl: coverUrl, placeholder: UIImage(named: "course_placeholder"))
        } else {
            cell.logoImageView.image = UIImage(named: "course_placeholder")
        }

        cell.markImageView.image = CourseDisplayHelper.getMarkImage(for: course)

        if let courseType = course?.type {
            switch courseType {
            case .course:
                cell.stateLabel.text = CourseStyle.getStatusText(forCourse: course)
                if let borderColor = CourseStyle.getStatusColor(for: course?.stats?.status) {
                    cell.stateLabel.layer.borderColor = borderColor.cgColor
                    cell.stateLabel.isHidden = false
                } else {
                    cell.stateLabel.isHidden = true
                }
            case .exam, .test:
                cell.stateLabel.text = CourseStyle.getStatusText(forExam: course)
                if let borderColor = CourseStyle.getStatusColor(for: course?.stats?.status) {
                    cell.stateLabel.layer.borderColor = borderColor.cgColor
                    cell.stateLabel.isHidden = false
                } else {
                    cell.stateLabel.isHidden = true
                }
            }
        } else {
            cell.stateLabel.isHidden = true
            cell.stateLabel.text = nil
        }

        cell.durationLabel.text = CourseDisplayHelper.getDurationText(for: course)
        cell.rateLabel.text = CourseDisplayHelper.getCourseRateText(for: course)
        cell.passedUsersLabel.text = CourseDisplayHelper.getCoursePassedUsersText(for: course)

        cell.bookmarkImageView.isHidden = (course?.isBookmarked != true)
        cell.checkmarkImageView.isHidden = (course?.stats?.status != .passed)
    }

    static func apply(to cell: InactiveCourseTableViewCell, inactiveCourse: Course?) {
        let titleAttributes = AppStyle.Text.courseTitleDefault
        let attributedTitle = inactiveCourse?.name?.attributed(with: titleAttributes)
        cell.titleLabel.attributedText = attributedTitle

        if let endDate = inactiveCourse?.endDate {
            let timePreposition = Localization.string("common.preposition_time")
            cell.dateLabel.text = endDate.dateTimeString(dateFormat: Date.dateFormatReadable,
                                                         timeFormat: Date.timeFormatReadable,
                                                         locale: Localization.language.locale,
                                                         timePreposition: timePreposition)
        } else {
            cell.dateLabel.text = nil
        }

        if let coverUrl = inactiveCourse?.coverUrl {
            cell.logoImageView.setImage(withUrl: coverUrl, placeholder: UIImage(named: "course_placeholder"))
        } else {
            cell.logoImageView.image = UIImage(named: "course_placeholder")
        }

        if let courseType = inactiveCourse?.type {
            let isSucceeded = inactiveCourse?.stats?.status != .failed

            cell.stateLabel.textColor = isSucceeded ? AppStyle.Color.success : AppStyle.Color.failure
            var resultText: String?
            switch courseType {
            case .course:
                let resultKey = isSucceeded ? "course.course_passed" : "course.course_failed"
                resultText = Localization.string(resultKey)
            case .exam:
                let resultKey = isSucceeded ? "course.certification_passed" : "course.certification_failed"
                resultText = Localization.string(resultKey)
            case .test:
                let resultKey = isSucceeded ? "course.test_passed" : "course.test_failed"
                resultText = Localization.string(resultKey)
            }
            let reasonText = inactiveCourse?.stats?.reason?.localized
            let text = [resultText, reasonText].compactMap({ $0 }).joined(separator: ": ")
            cell.stateLabel.text = text
        } else {
            cell.stateLabel.text = nil
        }
    }

    static func apply(to cell: AppointmentChapterTableViewCell, material: Material?) {
        cell.titleLabel.text = material?.name
        cell.stateImageView.image = MaterialDisplayHelper.getTypeImage(for: material)
        cell.titleLabel.attributedText = MaterialDisplayHelper.getTitleText(for: material)

        if material?.isActive == true {
            cell.titleLabel.textColor = AppStyle.Color.textSelected
            cell.selectionStyle = .default
        } else {
            cell.titleLabel.textColor = AppStyle.Color.textDeselected
            cell.selectionStyle = .none
        }
    }

    static func apply(to cell: AppointmentTestTableViewCell, material: Material?) {
        cell.titleLabel.text = material?.name
        cell.stateImageView.image = MaterialDisplayHelper.getTypeImage(for: material)
        cell.titleLabel.attributedText = MaterialDisplayHelper.getTitleText(for: material)

        if material?.isActive == true {
            cell.titleLabel.textColor = AppStyle.Color.textSelected
            cell.selectionStyle = .default
        } else {
            cell.titleLabel.textColor = AppStyle.Color.textDeselected
            cell.selectionStyle = .none
        }
    }

    static func apply(to cell: CourseInfoTableViewCell,
                      course: Course?) {
        let titleAttributes = AppStyle.Text.courseTitleDefault
        let attributedTitle = course?.name?.attributed(with: titleAttributes)
        cell.titleLabel.attributedText = attributedTitle

        cell.typeLabel.text = CourseDisplayHelper.getCourseTypeText(for: course)
        cell.typeImageView.image = CourseDisplayHelper.getCourseTypeImage(for: course)

        cell.markImageView.image = CourseDisplayHelper.getMarkImage(for: course)

        if let courseType = course?.type {
            switch courseType {
            case .course:
                cell.stateLabel.text = CourseStyle.getStatusText(forCourse: course)
                if let borderColor = CourseStyle.getStatusColor(for: course?.stats?.status) {
                    cell.stateLabel.layer.borderColor = borderColor.cgColor
                    cell.stateLabel.isHidden = false
                } else {
                    cell.stateLabel.isHidden = true
                }
            case .exam, .test:
                cell.stateLabel.text = CourseStyle.getStatusText(forExam: course)
                if let borderColor = CourseStyle.getStatusColor(for: course?.stats?.status) {
                    cell.stateLabel.layer.borderColor = borderColor.cgColor
                    cell.stateLabel.isHidden = false
                } else {
                    cell.stateLabel.isHidden = true
                }
            }
        } else {
            cell.stateLabel.isHidden = true
            cell.stateLabel.text = nil
        }

        if let coverUrl = course?.coverUrl {
            cell.logoImageView.setImage(withUrl: coverUrl, placeholder: UIImage(named: "course_placeholder"))
        } else {
            cell.logoImageView.image = UIImage(named: "course_placeholder")
        }

        cell.checkmarkImageView.isHidden = (course?.stats?.status != .passed)

        if let coursePrice = course?.price {
            switch coursePrice {
            case .free:
                cell.priceLabel.text = Localization.string("course.price.free")
            }
        } else {
            cell.priceLabel.text = nil
        }

        // TODO: remove later
        cell.priceLabel.text = Localization.string("course.price.free")
    }

    static func apply(to cell: CourseStatsTableViewCell,
                      course: Course?) {
        cell.rateLabel.text = CourseDisplayHelper.getCourseRateText(for: course)
        // TODO: implement later
        if let reviewsCount = course?.reviewsCount {
            cell.reviewsLabel.text = Localization.string(format: "plurable.reviews_count.VP", args: reviewsCount)
        } else {
            cell.reviewsLabel.text = nil
        }

        cell.passedLabel.text = Localization.string("course.users_passed")
        cell.passedValueLabel.text = CourseDisplayHelper.getCoursePassedUsersText(for: course)

        cell.complexityLabel.text = CourseDisplayHelper.getComplexityText(for: course)
        cell.complexityImageView.image = CourseDisplayHelper.getComplexityImage(for: course)

        cell.durationLabel.text = CourseDisplayHelper.getDurationText(for: course)

        cell.pgImageView.image = CourseDisplayHelper.getAgeRatingImage(for: course)
    }
}

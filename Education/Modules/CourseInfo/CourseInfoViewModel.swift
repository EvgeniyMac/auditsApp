//
//  CourseInfoViewModel.swift
//  Education
//
//  Created by Andrey Medvedev on 06/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

class CourseInfoViewModel {

    enum CourseInfoTableRow {
        case info(course: Course)
        case stats(course: Course)
        case button(course: Course)
        case material(course: Course, material: Material)
        case title(text: String, insetTop: Int, insetBottom: Int)
        case text(text: String)
        case tags(tags: [String])
        case rewards
    }

    enum CourseInfoType: Int {
        case content = 0
        case about
        case reviews

        func getTitle(for courseType: Course.CourseType?) -> String? {
            switch self {
            case .content:
                return Localization.string("course_info.content")
            case .about:
                guard let courseType = courseType else {
                    return nil
                }

                switch courseType {
                case .exam:
                    return Localization.string("course_info.about_certification")
                case .course:
                    return Localization.string("course_info.about_course")
                case .test:
                    return Localization.string("course_info.about_test")
                }
            case .reviews:
                return Localization.string("course_info.reviews")
            }
        }
    }

    public var availableInfoTabs: [CourseInfoType] {
        guard let courseType = self.course.type else {
            return []
        }

        return [.content, .about, .reviews]
    }

    public var selectedCourseInfoType = CourseInfoType.about {
        didSet {
            self.onUpdate?()
        }
    }
    public var courseRows: [CourseInfoTableRow]
    public var contentRows: [CourseInfoTableRow]
    public var aboutRows: [CourseInfoTableRow]
    public var reviewsRows: [CourseInfoTableRow]
    public var course: Course

    private var onUpdate: (() -> Void)?

    init(withCourse object: Course, onUpdate: (() -> Void)?) {
        self.course = object
        self.onUpdate = onUpdate

        self.courseRows = CourseInfoViewModel.getCourseRows(for: object)
        self.contentRows = CourseInfoViewModel.getContentRows(for: object)
        self.aboutRows = CourseInfoViewModel.getAboutRows(for: object)

        // TODO: implement later
        self.reviewsRows = [.text(text: Localization.string("common.under_construction"))]

        self.selectedCourseInfoType = self.availableInfoTabs.first ?? .about
    }

    public func setupCourse(_ object: Course) {
        self.course = object

        self.courseRows = CourseInfoViewModel.getCourseRows(for: object)
        self.contentRows = CourseInfoViewModel.getContentRows(for: object)
        self.aboutRows = CourseInfoViewModel.getAboutRows(for: object)

        // TODO: implement later
        self.reviewsRows = [.text(text: Localization.string("common.under_construction"))]

        self.selectedCourseInfoType = self.availableInfoTabs.first ?? .about

        self.onUpdate?()
    }

    public static func getButtonTitle(for course: Course) -> String? {
        guard let courseType = course.type else {
            return Localization.string("course_info.default_button")
        }

        switch courseType {
        case .course:
            if course.isMarketCourse {
                return Localization.string("course_info.start_button")
            }
            return getButtonTitle(byStatus: course.stats?.status)
        case .exam, .test:
            return getButtonTitleForExam(stats: course.stats)
        }
    }

    // MARK: - Private
    private static func getCourseRows(for course: Course) -> [CourseInfoTableRow] {
        var rows = [CourseInfoTableRow.info(course: course)]

        guard let type = course.type,
            let materials = course.materials,
            !materials.isEmpty else {
            return rows
        }

        if course.stats != nil {
            rows.append(CourseInfoTableRow.stats(course: course))
        }

        rows.append(.button(course: course))

        return rows
    }

    private static func getButtonTitleForExam(stats: CourseStats?) -> String? {
        guard let state = stats?.examState else {
            // if exam state not filled checking by status
            return getButtonTitle(byStatus: stats?.status)
        }

        switch state {
        case .proceed:
            return Localization.string("course_info.continue_button")
        case .retake:
            return Localization.string("course_info.retry_button")
        case .passed, .failed:
            return Localization.string("course_info.course.again_button")
        }
    }

    private static func getButtonTitle(byStatus: CourseStats.CourseStatus?) -> String? {
        guard let status = byStatus else {
            return Localization.string("course_info.default_button")
        }

        switch status {
        case .notStarted:
            return Localization.string("course_info.start_button")
        case .watched:
            return Localization.string("course_info.start_button")
        case .started:
            return Localization.string("course_info.continue_button")
        case .passed,
             .failed:
                 return Localization.string("course_info.course.again_button")
        case .overdue,
             .overduePassed,
             .overdueFailed:
                 return Localization.string("course_info.course.again_button")
        }
    }

    private static func getAboutRows(for course: Course) -> [CourseInfoTableRow] {
        var rows = [CourseInfoTableRow]()

        let rewardsTitleKey = "course_info.about.title.rewards"
        rows.append(.title(text: Localization.string(rewardsTitleKey), insetTop: 10, insetBottom: 20))
        rows.append(.rewards)

        var aboutTexts = [CourseInfoTableRow]()
        if let courseType = course.type {
            switch courseType {
            case .exam, .test:
                let text = CourseInfoViewModel.getCertificationInfo(for: course)
                if !text.isEmpty {
                    aboutTexts.append(.text(text: text))
                }
            case .course:
                break
            }
        }

        if let courseDescription = course.description,
            !courseDescription.isEmpty {
            aboutTexts.append(.text(text: courseDescription))
        }

        if !aboutTexts.isEmpty {
            if let courseType = course.type  {
                var key: String?
                switch courseType {
                case .exam:
                    key = "course_info.about.title.about_exam"
                case .course:
                    key = "course_info.about.title.about_course"
                case .test:
                    key = "course_info.about.title.about_test"
                }
                if let key = key {
                    rows.append(.title(text: Localization.string(key), insetTop: 0, insetBottom: 8))
                }
            }

            rows.append(contentsOf: aboutTexts)
        }

        if let tags = course.tags,
            !tags.isEmpty {
                rows.append(.tags(tags: tags))
        }

        return rows
    }

    private static func getContentRows(for course: Course) -> [CourseInfoTableRow] {
        return course.materials?.map({
            .material(course: course, material: $0)
        }) ?? []
    }

    private static func getCertificationInfo(for course: Course) -> String {
        return course.getDescriptionInfo()
    }
}

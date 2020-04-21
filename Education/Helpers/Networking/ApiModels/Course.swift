//
//  Course.swift
//  Education
//
//  Created by Andrey Medvedev on 18/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import ObjectMapper

class Course: Mappable {
    enum CourseComplexity: String {
        case simple
        case middle
        case hard
    }

    enum CourseType: String {
        case exam //certification
        case course
        case test
    }

    enum CourseMark: String {
        case best
        case recommended = "recommendation"
        case discount
    }

    enum CoursePrice: String {
        // TODO: implement later
        case free
    }

    enum AgeRating: Int {
        case rating0 = 0
        case rating6 = 6
        case rating12 = 12
        case rating16 = 16
        case rating18 = 18
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()

    var identifier: String?
    var name: String?
    var description: String?
    var type: CourseType?
    var coverUrl: URL?
    var startDate: Date?
    var endDate: Date?
    var timeout: Int?
    var materials: [Material]?
    var complexity: CourseComplexity?
    var rate: Double?
    var stats: CourseStats?
    var isRandomPassing: Bool?
    var allowableErrorsCount: Int?
    var attemptsCount: Int?
    var mark: CourseMark?
    var price: CoursePrice?
    var ageRating: AgeRating?
    var reviewsCount: Int?
    var tags: [String]?

    var isMarketCourse: Bool = false
    var isBookmarked: Bool = false

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        identifier <- map["_id"]
        identifier <- map["id"]
        name <- map["name"]
        description <- map["description"]
        type <- map["type"]
        coverUrl <- (map["cover"], URLTransform())
        startDate <- (map["start"], DateFormatterTransform(dateFormatter: Course.dateFormatter))
        endDate <- (map["end"], DateFormatterTransform(dateFormatter: Course.dateFormatter))
        timeout <- map["timeout"]
        materials <- map["materials"]
        complexity <- map["complexity"]
        rate <- map["point_avg"]
        stats <- map["statistic"]
        isRandomPassing <- (map["is_random_passing"], StringBoolTransform())
        allowableErrorsCount <- map["allowable_count_errors"]
        attemptsCount <- map["count_attempts"]
        mark <- map["mark"]
        ageRating <- map["age_rating"]
        reviewsCount <- map["total_count_rating"]
        tags <- map["tags"]

        isBookmarked <- map["is_here_bookmark"]
    }
}

extension Course {
    var isActive: Bool {
        guard let status = self.stats?.status else {
            return false
        }

        switch status {
        case .notStarted, .watched, .started:
            return true
        case .passed, .failed:
            return false
        case .overdue, .overduePassed, .overdueFailed:
            return false
        }
    }

    func getDescriptionInfo() -> String {
        var questionsString: String?
        if let material = self.materials?.first,
            let questionsCount = material.questionsCount,
            let duration = material.timeout {

            let questionsAmount = Localization.string(format: "plurable.questions.IP",
                                                      args: questionsCount)

            let minutes = Int(ceil(Double(duration) / 60.0))
            let minutesAmount = Localization.string(format: "plurable.minutes.VP", args: minutes)
            questionsString = Localization.string(format: "course.test_questions_format",
                                                  args: questionsAmount, minutesAmount)
        }

        var mistakesString: String?
        if let allowedErrorsCount = self.allowableErrorsCount {
            let titleString = Localization.string(format: "course.test_allowed_errors")
            mistakesString = "\(titleString): \(allowedErrorsCount)"
        }

        var attemptsString: String?
        if let attemptsCount = self.attemptsCount,
            let remainingAttemptsCount = getRemainingAttemptsCount() {

            if remainingAttemptsCount > 1 {
                let titleString = Localization.string(format: "course.number_of_attempts")
                attemptsString = "\(titleString): \(remainingAttemptsCount)/\(attemptsCount)"
            } else if remainingAttemptsCount == 1 {
                attemptsString = Localization.string(format: "course.one_attempt")
            }
        }

        return [questionsString, mistakesString, attemptsString]
            .compactMap({ $0 }).joined(separator: "\n")
    }

    func getRemainingAttemptsCount() -> Int? {
        guard let attemptsCount = self.attemptsCount else {
            return nil
        }
        let usedAttemptsCount = self.stats?.usedAttemptsCount ?? 0
        return attemptsCount - usedAttemptsCount
    }
}

extension Course {
    func getCongratulationsMessage() -> String? {
        guard let courseType = self.type else {
            return nil
        }

        switch courseType {
        case .course:
            if let courseName = self.name {
                let format = Localization.string("congratulations.course_passed_format")
                return String(format: format, courseName)
            } else {
                return Localization.string("congratulations.course_passed_text")
            }
        case .exam:
            if let courseName = self.name {
                let format = Localization.string("congratulations.certification_passed_format")
                return String(format: format, courseName)
            } else {
                return Localization.string("congratulations.certification_passed_text")
            }
        case .test:
            if let courseName = self.name {
                let format = Localization.string("congratulations.test_passed_format")
                return String(format: format, courseName)
            } else {
                return Localization.string("congratulations.test_passed_text")
            }
        }
    }
}

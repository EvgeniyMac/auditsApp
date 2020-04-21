//
//  Audit.swift
//  Education
//
//  Created by Andrey Medvedev on 19.02.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import ObjectMapper

struct AuditQuestionGroup: Mappable {

    var name: String?
    var questions: [AuditQuestion]?

    init?(map: Map) { }

    mutating func mapping(map: Map) {
        name <- map["name"]
        questions <- map["questions"]
    }
}

class Audit: Mappable {

    enum Role: String {
        case executor       // исполнитель
        case checking       // проверяющий
    }

    enum Status: String {
        case assigned = "audit_assigned"                    // назначен
        case watchedExecutor = "audit_watched_executor"     // просмотрен исполнителем
        case onRework = "audit_on_rework"                   // на доработке
        case onControl = "audit_on_control"                 // на контроле
        case accepted = "audit_accepted"                    // принят
        case acceptedCommented = "audit_accepted_comment"   // принят с коментом
        case failedCommented = "audit_failed_comment"       // провалена с замечаниями
        case failedTimeOut = "audit_failed_time_out"        // провалена (кончилось время)
    }

    enum ViewerStatus: String {
        case new = "audit_new"                              // новая
        case toPass = "audit_pass"                          // пройти
        case watched = "audit_watched"                      // просмотрена
        case toCheck = "audit_check"                        // проверить
        case onCheck = "audit_on_check"                     // на проверке
        case toModify = "audit_modify"                      // доработать
        case onModify = "audit_on_modify"                   // на доработке
        case accepted = "audit_accepted"                    // принята
        case acceptedCommented = "audit_accepted_comment"   // принята с замечаниями
        case failedTimeOut = "audit_failed_time_out"        // провалена (кончилось время)
        case failedCommented = "audit_failed_comment"       // провалена с замечаниями
        case notDefined = "audit_not_defined"               // не определена
    }

    enum AuditType: String {
        case audit
    }

    struct Media: Mappable {
        var images: [URL]

        // MARK: - Mappable
        init?(map: Map) {
            images = (try? map.value("images")) ?? []
        }

        func mapping(map: Map) { }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()

    var identifier: String?
    var libraryId: String?
    var name: String?
    var role: Role?
    var division: String?
    var startDate: Date?
    var endDate: Date?
    var type: Audit.AuditType?
    var timeZone: String?
    var slug: String?
    var gainedWeight: Int?
    var questionsWeightSum: Int?
    var viewerStatus: Audit.ViewerStatus?
    var status: Audit.Status?
    var statistic: AuditStats?
    var groupedQuestions: [AuditQuestionGroup]?
    var questionsTotal: Int?
    var media: Audit.Media?

    required init?(map: Map) { }

    func mapping(map: Map) {
        identifier <- map["id"]
        libraryId <- map["library_id"]
        name <- map["name"]
        role <- map["role"]
        division <- map["division"]
        startDate <- (map["start"],
                      DateFormatterTransform(dateFormatter: Audit.dateFormatter))
        endDate <- (map["end"],
                    DateFormatterTransform(dateFormatter: Audit.dateFormatter))
        type <- map["type"]
        timeZone <- map["time_zone"]
        slug <- map["slug"]
        gainedWeight <- map["gained_weight"]
        questionsWeightSum <- map["questions_weight_sum"]
        viewerStatus <- map["viewer_status"]
        status <- map["status"]
        statistic <- map["statistic"]
        groupedQuestions <- map["questions.data"]
        questionsTotal <- map["questions.total"]
        media <- map["media"]
    }
}

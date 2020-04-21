//
//  AuditQuestion.swift
//  Education
//
//  Created by Andrey Medvedev on 19.02.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import ObjectMapper

enum AuditQuestionType: String {
    case trueFalse = "true_false"
}

class AuditQuestion: Mappable {

    var identifier: String?
    var description: String?
    var section: String?
    var commentPreferences: AuditPreferences?
    var videoPreferences: AuditPreferences?
    var photoPreferences: AuditPreferences?
    var answers: [Answer]?
    var weight: Int?
    var questionType: AuditQuestionType?
    var questionText: String?
    var imageUrl: URL?
    var sort: Int?
    var mediaCount: Int?
    var status: Audit.Status?
    var userAnswer: AuditQuestionAnswer?

    required init?(map: Map) { }

    init() { }

    func mapping(map: Map) {
        identifier <- map["id"]
        description <- map["description"]
        section <- map["section"]
        commentPreferences <- map["comments"]
        videoPreferences <- map["video"]
        photoPreferences <- map["photo"]
        answers <- map["answers"]
        weight <- map["weight"]
        questionType <- map["type"]
        questionText <- map["text_question"]
        imageUrl <- (map["images"], URLTransform())
        sort <- map["sort"]
        mediaCount <- map["count_media"]
        status <- map["status"]
        userAnswer <- map["user_answer"]
    }
}

extension AuditQuestion {
    var canSendAnyMedia: Bool {
        return canSendPhoto || canSendVideo
    }

    var canSendPhoto: Bool {
        return canSendMedia(for: self.photoPreferences)
    }

    var canSendVideo: Bool {
        return canSendMedia(for: self.photoPreferences)
    }

    var commentRequired: Bool {
        // TODO: change when status from backend will be ready
        return true
    }

    private func canSendMedia(for prefs: AuditPreferences?) -> Bool {
        guard let requirement = prefs?.requirement else {
            return false
        }

        switch requirement {
        case .required, .optional:
            return true
        case .no:
            return false
        }
    }
}

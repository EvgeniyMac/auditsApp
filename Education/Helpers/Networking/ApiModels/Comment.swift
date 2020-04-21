//
//  Comment.swift
//  Education
//
//  Created by Andrey Medvedev on 10.03.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import ObjectMapper

struct Comment: Mappable {

    public enum ObjectType: String {
        case answer = "answers_session"
    }

    struct Meta: Mappable {
        let questionId: String?

        init(questionId: String?) {
            self.questionId = questionId
        }

        // MARK: - Mappable
        init?(map: Map) {
            questionId = try! map.value("question_id")
        }

        func mapping(map: Map) {
            questionId >>> map["question_id"]
        }
    }

    let identifier: String?
    let dateTime: Date?
    let userName: String?

    let comment: String?
    let objectId: String?
    let objectType: Comment.ObjectType?
    let meta: Comment.Meta?

    init(text: String?,
         objectId: String?,
         objectType: Comment.ObjectType,
         meta: Comment.Meta) {
        self.identifier = nil
        self.dateTime = nil
        self.userName = nil

        self.comment = text
        self.objectId = objectId
        self.objectType = objectType
        self.meta = meta
    }

    // MARK: - Mappable
    init?(map: Map) {
        identifier = try? map.value("id")
        dateTime = try? map.value("time", using: DateTransform())
        userName = try? map.value("user_name")

        comment = try? map.value("comment")
        objectId = try? map.value("object_id")
        objectType = try? map.value("object_type")
        meta = try? map.value("meta")
    }

    func mapping(map: Map) {
        comment >>> map["comment"]
        objectId >>> map["object_id"]
        objectType >>> (map["object_type"], EnumTransform<Comment.ObjectType>())
        meta >>> map["meta"]
    }
}

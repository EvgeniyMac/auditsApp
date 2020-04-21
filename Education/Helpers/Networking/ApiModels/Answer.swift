//
//  Answer.swift
//  Education
//
//  Created by Andrey Medvedev on 26/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import ObjectMapper

class Answer: Mappable {

    var identifier: String?
    var answer: String?
    var trueAnswer: String?
    var isTrue: Bool?
    var key: String?
    var value: String?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        identifier <- map["id"]
        answer <- map["answer"]
        trueAnswer <- map["true_answer"]
        isTrue <- map["is_true"]
        key <- map["key"]
        value <- map["value"]
    }
}

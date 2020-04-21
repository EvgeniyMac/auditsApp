//
//  AuditPreferences.swift
//  Education
//
//  Created by Andrey Medvedev on 04.03.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import ObjectMapper

struct AuditPreferences: Mappable {
    enum Requirement: String {
//            case notRequired = "not_required"
        // necessary
        case required
        case optional
        case no
    }

    let requirement: Requirement?
    let count: Int?

    // MARK: - Mappable
    init?(map: Map) {
        requirement = try? map.value("type")
        count = try? map.value("count")
    }

    mutating func mapping(map: Map) {
        requirement >>> map["type"]
        count >>> map["count"]
    }
}

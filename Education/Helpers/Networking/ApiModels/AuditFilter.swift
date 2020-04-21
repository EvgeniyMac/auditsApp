//
//  AuditFilter.swift
//  Education
//
//  Created by Andrey Medvedev on 19.02.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import ObjectMapper

class AuditFilter: Mappable {
    var userIds: [Int]?
    var divisionIds: [Int]?
    var startDate: Date?
    var endDate: Date?
    var statuses: [Audit.Status]?

    required init?(map: Map) { }

    init() { }

    func mapping(map: Map) {
        userIds <- map["user_ids"]
        divisionIds <- map["division_ids"]
        startDate <- map["time_start"]
        endDate <- map["time_end"]
        statuses <- map["statuses"]
    }
}

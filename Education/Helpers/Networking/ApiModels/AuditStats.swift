//
//  AuditStats.swift
//  Education
//
//  Created by Andrey Medvedev on 19.02.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import ObjectMapper

class AuditStats: Mappable {
    var checkedCount: Int?
    var checksTotalCount: Int?

    required init?(map: Map) { }

    func mapping(map: Map) {
        checkedCount <- map["count_checked"]
        checksTotalCount <- map["total_count_checks"]
    }
}

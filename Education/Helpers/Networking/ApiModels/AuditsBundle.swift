//
//  AuditsBundle.swift
//  Education
//
//  Created by Andrey Medvedev on 19.02.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import ObjectMapper

class AuditsBundle: Mappable {

    var list: [Audit]?
    var totalCount: Int?

    required init?(map: Map) { }

    func mapping(map: Map) {
        list <- map["data"]
        totalCount <- map["meta.total"]
    }
}

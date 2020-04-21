//
//  CoursesBundle.swift
//  Education
//
//  Created by Andrey Medvedev on 01/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import ObjectMapper

class CoursesBundle: Mappable {

    var recommended: [Course]
    var mine: [Course]
    var market: [Course]

    var recommendedCount: Int?
    var mineCount: Int?
    var marketCount: Int?

    var stats: CommonStats?

    required init?(map: Map) {
        self.recommended = (try? map.value("data.recommended.data")) ?? []
        self.mine = (try? map.value("data.mine.data")) ?? []
        self.market = (try? map.value("data.market.data")) ?? []
    }

    func mapping(map: Map) {
        recommendedCount <- map["data.recommended.total"]
        mineCount <- map["data.mine.total"]
        marketCount <- map["data.market.total"]
        stats <- map["statistics"]
    }
}

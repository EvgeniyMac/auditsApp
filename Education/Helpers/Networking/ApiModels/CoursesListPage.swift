//
//  CoursesListPage.swift
//  Education
//
//  Created by Andrey Medvedev on 28/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import ObjectMapper

class CoursesListPage: Mappable {

    var courses: [Course]
    var stats: CommonStats?

    required init?(map: Map) {
        self.courses = (try? map.value("data")) ?? []
    }

    func mapping(map: Map) {
        stats <- map["statistics"]
    }
}

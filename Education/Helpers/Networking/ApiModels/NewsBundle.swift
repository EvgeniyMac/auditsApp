//
//  NewsBundle.swift
//  Education
//
//  Created by Andrey Medvedev on 07.02.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import Foundation
import ObjectMapper

class NewsBundle: Mappable {

    var list: [NewsItem]?
    var totalCount: Int?

    required init?(map: Map) { }

    func mapping(map: Map) {
        list <- map["data"]
        totalCount <- map["meta.total"]
    }
}

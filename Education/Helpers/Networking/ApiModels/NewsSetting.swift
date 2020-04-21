//
//  NewsSetting.swift
//  Education
//
//  Created by Andrey Medvedev on 20.12.2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation
import ObjectMapper

class NewsSetting: Mappable {
    enum DisplayType: String {
        case full = "fill_full"
        case half = "fill_half"
        case quarter = "fill_quarter"
    }

    enum DatePlacementType: String {
        case always
        case period
    }

    var displayType: DisplayType?
    var datePlacementType: DatePlacementType?
    var timeStart: Date?
    var timeEnd: Date?

    required init?(map: Map) { }

    func mapping(map: Map) {
        displayType <- map["mobile_view_type"]
        datePlacementType <- map["date_placement_type"]
        timeStart <- (map["time_start.$date.$numberLong"], DateTimeIntervalTransform())
        timeEnd <- (map["time_end.$date.$numberLong"], DateTimeIntervalTransform())
    }
}

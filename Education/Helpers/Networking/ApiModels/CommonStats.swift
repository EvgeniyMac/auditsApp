//
//  CommonStats.swift
//  Education
//
//  Created by Andrey Medvedev on 21/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import ObjectMapper

class CommonStats: Mappable {

    var newAppointmentsCount: Int?

    required init?(map: Map) { }

    func mapping(map: Map) {
        newAppointmentsCount <- map["count_new_appointment"]
    }
}

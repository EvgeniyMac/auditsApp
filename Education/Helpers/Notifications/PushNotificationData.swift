//
//  PushNotificationData.swift
//  Education
//
//  Created by Andrey Medvedev on 24.02.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import ObjectMapper

class PushNotificationData: Mappable {

    var appointmentId: String?
    var articleId: String?

    required init?(map: Map) { }

    func mapping(map: Map) {
        appointmentId <- map["appointment_id"]
        articleId <- map["article_id"]
    }
}

//
//  User.swift
//  Education
//
//  Created by Andrey Medvedev on 05/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation
import ObjectMapper

class User: Mappable {

    var name: String?
    var email: String?
    var phone: String?
    var division: String?
    var position: String?
    var logo: URL?


    required init?(map: Map) {
    }

    func mapping(map: Map) {
        name <- map["name"]
        email <- map["email"]
        phone <- map["phone"]
        division <- map["division"]
        position <- map["position"]
        logo <- (map["logo"], URLTransform())
    }
}

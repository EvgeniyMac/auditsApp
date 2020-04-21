//
//  ValidationError.swift
//  Education
//
//  Created by Andrey Medvedev on 16/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import ObjectMapper

class AuthError: Mappable {
    var code: String?
    var message: String?

    required init?(map: Map) {
        if map["error"].currentValue == nil {
            return nil
        }
    }

    func mapping(map: Map) {
        code <- map["error"]
        message <- map["message"]
    }
}

//
//  ServerError.swift
//  Education
//
//  Created by Andrey Medvedev on 16/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import ObjectMapper

class ServerError: Mappable {
    enum ErrorType: String {
        case versionNotSupported = "VersionNotSupported"
    }

    var code: Int?
    var message: String?
    var type: ErrorType?
    var errors: [String : [String]]?

    required init?(map: Map) {
        if map["message"].currentValue == nil {
            return nil
        }
    }

    func mapping(map: Map) {
        code <- map["code"]
        message <- map["message"]
        type <- map["type"]
        errors <- map["errors"]
    }
}

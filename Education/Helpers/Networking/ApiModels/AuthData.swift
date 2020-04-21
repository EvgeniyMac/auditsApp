//
//  AuthData.swift
//  Education
//
//  Created by Andrey Medvedev on 16/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation
import ObjectMapper

class AuthData: Codable, Mappable {

    var tokenType: String?
    var expirationDate: Date?
    var accessToken: String?
    var refreshToken: String?

    required init?(map: Map) {
        if map["access_token"].currentValue == nil ||
            map["refresh_token"].currentValue == nil {
            return nil
        }
    }

    func mapping(map: Map) {
        tokenType <- map["token_type"]
        expirationDate <- (map["expires_in"], DateSinceNowTransform())
        accessToken <- map["access_token"]
        refreshToken <- map["refresh_token"]
    }
}

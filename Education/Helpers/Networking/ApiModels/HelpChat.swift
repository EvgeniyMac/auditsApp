//
//  HelpChat.swift
//  Education
//
//  Created by Andrey Medvedev on 24.12.2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import ObjectMapper

class HelpChat: Mappable {
    var content: String?

    required init?(map: Map) { }

    func mapping(map: Map) {
        content <- map["content"]
    }
}

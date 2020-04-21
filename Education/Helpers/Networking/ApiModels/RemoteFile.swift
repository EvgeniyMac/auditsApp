//
//  RemoteFile.swift
//  Education
//
//  Created by Andrey Medvedev on 11.03.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import ObjectMapper

struct RemoteFile: Mappable {

    let identifier: String?
    let url: URL?

    // MARK: - Mappable
    init?(map: Map) {
        identifier = try? map.value("id")
        url = try? map.value("url", using: URLTransform())
    }

    func mapping(map: Map) {
        identifier >>> map["id"]
        url >>> map["url"]
    }
}

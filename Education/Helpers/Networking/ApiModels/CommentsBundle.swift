//
//  CommentsBundle.swift
//  Education
//
//  Created by Andrey Medvedev on 13.03.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import ObjectMapper

struct CommentsBundle: Mappable {

    var list: [Comment]
    var meta: BundleMeta?

    init() {
        self.list = []
        self.meta = nil
    }

    init(list: [Comment], meta: BundleMeta?) {
        self.list = list
        self.meta = meta
    }

    // MARK: - Mappable
    init?(map: Map) {
        list = (try? map.value("data")) ?? []
        meta = try? map.value("meta")
    }

    func mapping(map: Map) { }
}

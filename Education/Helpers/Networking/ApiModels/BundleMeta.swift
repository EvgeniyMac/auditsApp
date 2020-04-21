//
//  BundleMeta.swift
//  Education
//
//  Created by Andrey Medvedev on 13.03.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import ObjectMapper

struct BundleMeta: Mappable {

    let currentPage: Int?
    let lastPage: Int?
    let perPage: Int?
    let totalCount: Int?

    // MARK: - Mappable
    init?(map: Map) {
        currentPage = try? map.value("current_page")
        lastPage = try? map.value("last_page")
        perPage = try? map.value("per_page")
        totalCount = try? map.value("total")
    }

    func mapping(map: Map) { }
}

extension BundleMeta {
    var nextPage: Int? {
        guard let currentPage = self.currentPage else {
            return nil
        }
        return self.hasNext ? (currentPage + 1) : nil
    }

    var hasNext: Bool {
        guard let currentPage = self.currentPage,
            let lastPage = self.lastPage else {
                return false
        }

        return currentPage < lastPage
    }

    var isLast: Bool {
        guard let currentPage = self.currentPage,
            let lastPage = self.lastPage else {
                return false
        }

        return currentPage == lastPage
    }
}

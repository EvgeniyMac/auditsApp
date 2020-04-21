//
//  NewsItem.swift
//  Education
//
//  Created by Andrey Medvedev on 19.12.2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation
import ObjectMapper

class NewsItem: Mappable {

    var identifier: String?
    var name: String?
    var categoryName: String?
    var isFavorite: Bool = false
    var authorName: String?
    var content: String?
    var description: String?
    var setting: NewsSetting?
    var dateCreated: Date?
    var timePublished: Date?
    var logo: URL?

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z"
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()

    required init?(map: Map) { }

    func mapping(map: Map) {
        identifier <- map["id"]
        name <- map["name"]
        categoryName <- map["category_name"]
        isFavorite <- map["is_favorite"]
        authorName <- map["author_name"]
        content <- map["content"]
        description <- map["description"]
        setting <- map["setting"]
        dateCreated <- (map["created_at"],
                        DateFormatterTransform(dateFormatter: NewsItem.dateFormatter))
        timePublished <- (map["time_publish"],
                          DateFormatterTransform(dateFormatter: NewsItem.timeFormatter))
        logo <- (map["logo_url"], URLTransform())
    }
}

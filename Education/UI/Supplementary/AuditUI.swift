//
//  AuditUI.swift
//  Education
//
//  Created by Andrey Medvedev on 29.02.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import UIKit

struct AuditUI {

    struct Question {
        let rows: [AuditUI.Row]
    }

    enum Row {
        case groupTitle(text: String)
        case title(question: AuditQuestion)//(title: String?, subtitle: String?)
        case image(question: AuditQuestion)//(url: URL)
        case imagesPreview(question: AuditQuestion, index: Int, images: [URL])
        case options(question: AuditQuestion, index: Int)
        case media(question: AuditQuestion, index: Int, images: [URL])
        case input(question: AuditQuestion, index: Int)
        case comment(comment: Comment)
        case space(height: CGFloat)
    }

    enum Tab: Int {
        case list = 0
        case photo
        case result

        var title: String {
            switch self {
            case .list:
                return Localization.string("audit.details.tab.list")
            case .photo:
                return Localization.string("audit.details.tab.photo")
            case .result:
                return Localization.string("audit.details.tab.result")
            }
        }
    }

}

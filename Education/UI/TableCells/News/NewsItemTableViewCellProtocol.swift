//
//  NewsItemTableViewCellProtocol.swift
//  Education
//
//  Created by Andrey Medvedev on 21.12.2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

protocol NewsItemTableViewCellProtocol where Self: UITableViewCell {
    func setup(with newsItem: NewsItem)
}

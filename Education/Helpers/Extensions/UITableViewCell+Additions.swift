//
//  UITableViewCell+Additions.swift
//  Education
//
//  Created by Andrey Medvedev on 17/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

extension UITableViewCell {
    static func reuseIdentifier() -> String {
        return String(describing: self)
    }

    static func registerNib(at table: UITableView) {
        let cellName = self.reuseIdentifier()
        let nib = UINib(nibName: cellName, bundle: nil)
        table.register(nib, forCellReuseIdentifier: cellName)
    }
}

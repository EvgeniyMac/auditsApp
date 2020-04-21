//
//  UITableView+Additions.swift
//  Education
//
//  Created by Andrey Medvedev on 11/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

extension UITableView {
    func dequeCell<T: UITableViewCell>(at indexPath: IndexPath) -> T {
        let cellId = T.reuseIdentifier()
        let cellItem = self.dequeueReusableCell(withIdentifier: cellId,
                                                for: indexPath)
        guard let cell = cellItem as? T else {
            fatalError("Unable to create \(cellId)")
        }
        return cell
    }
}

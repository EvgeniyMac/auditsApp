//
//  UICollectionView+Additions.swift
//  Education
//
//  Created by Andrey Medvedev on 11/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

extension UICollectionView {
    func dequeCell<T: UICollectionViewCell>(at indexPath: IndexPath) -> T {
        let cellId = T.viewReuseIdentifier()
        let cellItem = self.dequeueReusableCell(withReuseIdentifier: cellId,
                                                for: indexPath)
        guard let cell = cellItem as? T else {
            fatalError("Unable to create \(cellId)")
        }
        return cell
    }
}

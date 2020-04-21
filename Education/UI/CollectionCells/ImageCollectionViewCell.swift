//
//  ImageCollectionViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 15.03.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = UIColor.clear
        self.imageView.contentMode = .scaleAspectFill
    }
}

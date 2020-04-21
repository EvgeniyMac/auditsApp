//
//  ImageTileCollectionViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 07/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class ImageTileCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var answerContainer: UIView!
    @IBOutlet weak var answerLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = UIColor.clear
        self.imageView.layer.cornerRadius = AppStyle.CornerRadius.tile
        self.imageView.layer.masksToBounds = true
        self.imageView.contentMode = .scaleAspectFill

        self.titleLabel.textColor = AppStyle.Color.textMain
        self.titleLabel.font = AppStyle.Font.medium(16)
        self.titleLabel.textAlignment = .center
        self.titleLabel.numberOfLines = 0
        self.titleLabel.setContentCompressionResistancePriority(UILayoutPriority(1),
                                                                for: .horizontal)
        self.titleLabel.setContentCompressionResistancePriority(UILayoutPriority(2),
                                                                for: .vertical)

        self.answerLabel.textColor = AppStyle.Color.darkGray
        self.answerLabel.font = AppStyle.Font.medium(16)
        self.answerLabel.textAlignment = .center
        self.answerLabel.numberOfLines = 0
        self.answerLabel.setContentCompressionResistancePriority(UILayoutPriority(1),
                                                                 for: .horizontal)
        self.answerLabel.setContentCompressionResistancePriority(UILayoutPriority(1),
                                                                 for: .vertical)

        self.answerContainer.layer.cornerRadius = AppStyle.CornerRadius.textCell
        self.answerContainer.layer.masksToBounds = true
        self.answerContainer.backgroundColor = AppStyle.Color.optionMain
    }
}

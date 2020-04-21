//
//  WalkthroughCollectionViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 12/11/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class WalkthroughCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.imageView.contentMode = .scaleAspectFit
        self.imageView.setContentHuggingPriority(UILayoutPriority(100), for: .vertical)
        self.imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        self.titleLabel.font = AppStyle.Font.bold(30)
        self.titleLabel.textColor = AppStyle.Color.textMain
        self.titleLabel.textAlignment = .center
        self.titleLabel.numberOfLines = 0

        self.subtitleLabel.font = AppStyle.Font.regular(16)
        self.subtitleLabel.textColor = AppStyle.Color.textSupplementary
        self.subtitleLabel.textAlignment = .center
        self.subtitleLabel.numberOfLines = 0
    }
}

//
//  AddMediaCollectionViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 15.03.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import UIKit

class AddMediaCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = UIColor.clear
        self.mediaImageView.contentMode = .scaleAspectFit

        self.infoLabel.font = AppStyle.Font.regular(14)
        self.infoLabel.textColor = AppStyle.Color.tintUnselected
        self.infoLabel.text = nil
    }

    func setupAsPhoto() {
        self.mediaImageView.image = UIImage(named: "photo_icon2")
    }

    func setupAsVideo() {
        self.mediaImageView.image = UIImage(named: "video_icon")
    }
}

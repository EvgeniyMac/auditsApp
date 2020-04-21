//
//  CourseStatsTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 02/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class CourseStatsTableViewCell: UITableViewCell {

    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var reviewsLabel: UILabel!
    
    @IBOutlet weak var passedLabel: UILabel!
    @IBOutlet weak var passedValueLabel: UILabel!

    @IBOutlet weak var complexityImageView: UIImageView!
    @IBOutlet weak var complexityLabel: UILabel!

    @IBOutlet weak var durationLabel: UILabel!

    @IBOutlet weak var pgImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        [rateLabel,
        reviewsLabel,
        passedLabel,
        passedValueLabel,
        complexityLabel,
        durationLabel].forEach { label in
            label?.font = AppStyle.Font.regular(12)
            label?.textColor = AppStyle.Color.textMainBrightened
            label?.numberOfLines = 0
        }
    }
}

//
//  TextCollectionViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 10/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class TextCollectionViewCell: UICollectionViewCell {

    enum State {
        case available
        case selected
    }

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var textLabel: UILabel!

    var fitToTextHorizontally: Bool = true
    var fitToTextVertically: Bool = true

    var state: TextCollectionViewCell.State = .available {
        didSet {
            switch self.state {
            case .available:
                self.textLabel.alpha = AppStyle.Alpha.default
                self.container.backgroundColor = AppStyle.Color.optionMain
            case .selected:
                self.textLabel.alpha = AppStyle.Alpha.hidden
                self.container.backgroundColor = AppStyle.Color.optionSecondary
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear

        self.container.layer.cornerRadius = AppStyle.CornerRadius.textCell
        self.container.layer.masksToBounds = true

        self.textLabel.textColor = AppStyle.Color.darkGray
        self.textLabel.font = AppStyle.Font.medium(16)
        self.textLabel.numberOfLines = 0
        self.textLabel.preferredMaxLayoutWidth = 130
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        // Specify you want _full width_
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 30)

        // Setting priorities for Auto Layout
        func fittingPriority(shouldFit: Bool) -> UILayoutPriority {
            return shouldFit ? .defaultLow : .defaultHigh
        }
        let horizontalFitting = fittingPriority(shouldFit: fitToTextHorizontally)
        let verticalFitting = fittingPriority(shouldFit: fitToTextVertically)

        // Calculate the size (height) using Auto Layout
        let autoLayoutSize = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFitting, verticalFittingPriority: verticalFitting)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: autoLayoutSize)

        // Assign the new size to the layout attributes
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}

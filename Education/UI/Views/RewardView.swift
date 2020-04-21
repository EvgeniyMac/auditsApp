//
//  RewardView.swift
//  Education
//
//  Created by Andrey Medvedev on 14/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class RewardView: UIView {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = AppStyle.Color.textMain
        label.font = AppStyle.Font.regular(14)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    let rewardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.clear
        setupRewardViewLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.backgroundColor = UIColor.clear
        setupRewardViewLayout()
    }

    // MARK: - Actions

    // MARK: - Private
    private func setupRewardViewLayout() {
        self.addSubview(self.rewardImageView)
        self.addConstraints([self.createContiguousConstraint(toItem: self.rewardImageView,
                                                             attribute: .centerX),
                             self.createContiguousConstraint(toItem: self.rewardImageView,
                                                             attribute: .top)])
        self.rewardImageView.addSizeConstraints(width: 45, height: 45)

        self.addSubview(self.titleLabel)
        self.addConstraints([self.createContiguousConstraint(toItem: self.titleLabel,
                                                             attribute: .left,
                                                             inset: 15),
                             self.createContiguousConstraint(toItem: self.titleLabel,
                                                             attribute: .centerX)])

        self.addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .bottom,
                                              relatedBy: .greaterThanOrEqual,
                                              toItem: self.titleLabel,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 7.0))
        self.addConstraint(NSLayoutConstraint(item: self.rewardImageView,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self.titleLabel,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: -7.0))
    }
}

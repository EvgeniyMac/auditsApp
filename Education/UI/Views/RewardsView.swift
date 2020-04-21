//
//  RewardsView.swift
//  Education
//
//  Created by Andrey Medvedev on 14/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class RewardsView: UIView {

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.backgroundColor = UIColor.clear
        stack.spacing = CGFloat.zero
        return stack
    }()

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.clear
        setupRewardsViewLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.backgroundColor = UIColor.clear
        setupRewardsViewLayout()
    }

    // MARK: - Public
    public func showDemoData() {
        // TODO: remove later
        let reward1 = RewardView()
        reward1.rewardImageView.image = UIImage(named: "reward.at_time")
        reward1.titleLabel.text = Localization.string("reward.at_time.title")
        let reward2 = RewardView()
        reward2.rewardImageView.image = UIImage(named: "reward.first")
        reward2.titleLabel.text = Localization.string("reward.first.title")
        let reward3 = RewardView()
        reward3.rewardImageView.image = UIImage(named: "reward.respect")
        reward3.titleLabel.text = Localization.string("reward.no_mistakes.title")
        self.setup(rewardViews: [reward1, reward2, reward3])
    }

    public func setup(rewardViews: [RewardView]) {
        self.stackView.removeAllArrangedSubviews()
        for rewardView in rewardViews {
            self.stackView.addArrangedSubview(rewardView)
        }
    }

    // MARK: - Actions

    // MARK: - Private
    private func setupRewardsViewLayout() {
        self.addSubview(self.stackView)
        let stackInsets = UIEdgeInsets(top: 0, left: 15, bottom: 20, right: 15)
        let constraints = self.createContiguousConstraints(toView: self.stackView,
                                                           insets: stackInsets)
        self.addConstraints(constraints)

        self.stackView.addSizeConstraints(height: 90)
    }
}

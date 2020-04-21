//
//  AvatarView.swift
//  Education
//
//  Created by Andrey Medvedev on 04/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class AvatarView: UIView {
    public let containerView = RoundedView()
    public let monogramLabel = UILabel()
    public let avatarImageView = UIImageView()
    public let avatarButton = UIButton()

    private let avatarContainerInset = CGPoint.zero

    init() {
        super.init(frame: .zero)
        setupSubViews()
        configureUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubViews()
        configureUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubViews()
        configureUI()
    }

    private func configureUI() {
        self.containerView.backgroundColor = AppStyle.Color.avatarBackground
        self.monogramLabel.textColor = AppStyle.Color.avatarText
        self.monogramLabel.textAlignment = .center
        self.monogramLabel.font = AppStyle.Font.regular(32)
        self.monogramLabel.adjustsFontSizeToFitWidth = true
        self.monogramLabel.numberOfLines = 1
        self.monogramLabel.minimumScaleFactor = 0.01
        self.avatarImageView.contentMode = .scaleAspectFill
    }

    private func setupSubViews() {
        setupContainerConstraints()
        setupMonogramConstraints()
        setupAvatarImageConstraints()
        setupAvatarButtonConstraints()
    }

    private func setupContainerConstraints() {
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.containerView)
        let containerConstraints = [
            self.createContiguousConstraint(toItem: self.containerView,
                                            attribute: .centerX),
            self.createContiguousConstraint(toItem: self.containerView,
                                            attribute: .centerY),
            NSLayoutConstraint(item: self,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: self.containerView,
                               attribute: .top,
                               multiplier: 1.0,
                               constant: avatarContainerInset.y),
            NSLayoutConstraint(item: self,
                               attribute: .leading,
                               relatedBy: .equal,
                               toItem: self.containerView,
                               attribute: .leading,
                               multiplier: 1.0,
                               constant: avatarContainerInset.x)
        ]
        self.addConstraints(containerConstraints)

        let constraints = self.containerView.createRatioConstraint(ratio: 1.0)
        self.containerView.addConstraint(constraints)
    }

    private func setupMonogramConstraints() {
        self.monogramLabel.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(self.monogramLabel)
        let constraints = [
            self.containerView.createContiguousConstraint(toItem: self.monogramLabel,
                                                          attribute: .centerX),
            self.containerView.createContiguousConstraint(toItem: self.monogramLabel,
                                                          attribute: .centerY),
            self.containerView.createProportionalConstraint(toItem: self.monogramLabel,
                                                            attribute: .width,
                                                            ratio: 1.8,
                                                            inset: 0),
            self.containerView.createProportionalConstraint(toItem: self.monogramLabel,
                                                            attribute: .height,
                                                            ratio: 1.8,
                                                            inset: 0)
        ]
        self.containerView.addConstraints(constraints)
    }

    private func setupAvatarImageConstraints() {
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(self.avatarImageView)
        let constraints = self.containerView.createContiguousConstraints(toView: self.avatarImageView)
        self.containerView.addConstraints(constraints)
    }

    private func setupAvatarButtonConstraints() {
        self.avatarButton.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(self.avatarButton)
        let constraints = self.containerView.createContiguousConstraints(toView: self.avatarButton)
        self.containerView.addConstraints(constraints)
    }
}

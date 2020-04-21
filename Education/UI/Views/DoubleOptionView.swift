//
//  DoubleOptionView.swift
//  Education
//
//  Created by Andrey Medvedev on 25/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class DoubleOptionView: UIView {

    let leftOptionButton: CustomButton = CustomButton()
    let rightOptionButton: CustomButton = CustomButton()

    var onPressLeftButton: (() -> Void)?
    var onPressRightButton: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDoubleOptionViewLayout()
        setupDoubleOptionViewTargets()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDoubleOptionViewLayout()
        setupDoubleOptionViewTargets()
    }

    // MARK: - Actions
    @objc private func didPressLeftButton(_ sender: UIButton) {
        self.onPressLeftButton?()
    }

    @objc private func didPressRightButton(_ sender: UIButton) {
        self.onPressRightButton?()
    }

    // MARK: - Private
    private func setupDoubleOptionViewTargets() {
        self.leftOptionButton.addTarget(self,
                                        action: #selector(didPressLeftButton(_:)),
                                        for: .touchUpInside)
        self.rightOptionButton.addTarget(self,
                                         action: #selector(didPressRightButton(_:)),
                                         for: .touchUpInside)
    }

    private func setupDoubleOptionViewLayout() {
        self.leftOptionButton.translatesAutoresizingMaskIntoConstraints = false
        self.rightOptionButton.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.leftOptionButton)
        self.leftOptionButton.addSizeConstraints(height: 50)

        self.addSubview(self.rightOptionButton)
        self.rightOptionButton.addSizeConstraints(height: 50)

        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: self.leftOptionButton,
                                              attribute: .right,
                                              multiplier: 1.0,
                                              constant: 16))
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: self.rightOptionButton,
                                              attribute: .left,
                                              multiplier: 1.0,
                                              constant: -16))
        constraints.append(NSLayoutConstraint(item: self.leftOptionButton,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: self.rightOptionButton,
                                              attribute: .width,
                                              multiplier: 1.0,
                                              constant: 0.0))

        constraints.append(contentsOf: verticalConstraints(to: self.leftOptionButton))
        constraints.append(contentsOf: verticalConstraints(to: self.rightOptionButton))

        self.addConstraints(constraints)
    }

    private func verticalConstraints(to button: UIButton) -> [NSLayoutConstraint] {
        return [NSLayoutConstraint(item: self,
                                   attribute: .centerY,
                                   relatedBy: .equal,
                                   toItem: button,
                                   attribute: .centerY,
                                   multiplier: 1.0,
                                   constant: 0),
                NSLayoutConstraint(item: self,
                                   attribute: .bottom,
                                   relatedBy: .equal,
                                   toItem: button,
                                   attribute: .bottom,
                                   multiplier: 1.0,
                                   constant: 27)]
    }
}

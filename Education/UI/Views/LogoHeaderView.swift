//
//  LogoHeaderView.swift
//  Education
//
//  Created by Andrey Medvedev on 02/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class LogoHeaderView: UIView {
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = UIView.ContentMode.scaleAspectFit
        return view
    }()

    init() {
        super.init(frame: .zero)
        setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    // MARK: - Private
    private func setupSubviews() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.imageView)

        let constraints = [createContiguousConstraint(toItem: self.imageView, attribute: .centerX),
                           createContiguousConstraint(toItem: self.imageView, attribute: .centerY),
                           createProportionalConstraint(toItem: self.imageView, attribute: .width, ratio: 2.0),
                           createProportionalConstraint(toItem: self.imageView, attribute: .height, ratio: 1.5)]
        self.addConstraints(constraints)
    }
}

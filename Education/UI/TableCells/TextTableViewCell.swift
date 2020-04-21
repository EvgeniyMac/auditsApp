//
//  TextTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 25/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class TextTableViewCell: UITableViewCell {

    var insets = UIEdgeInsets.zero {
        didSet {
            updateConstraintsWith(edgeInsets: insets)
        }
    }

    @IBOutlet weak var contentLabel: UILabel!

    @IBOutlet private weak var labelLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var labelRightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var labelTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var labelBottomConstraint: NSLayoutConstraint!

    private func updateConstraintsWith(edgeInsets: UIEdgeInsets) {
        self.labelLeftConstraint.constant = edgeInsets.left
        self.labelRightConstraint.constant = edgeInsets.right
        self.labelTopConstraint.constant = edgeInsets.top
        self.labelBottomConstraint.constant = edgeInsets.bottom
    }
}

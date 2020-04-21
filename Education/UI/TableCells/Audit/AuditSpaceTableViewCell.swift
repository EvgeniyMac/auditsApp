//
//  AuditSpaceTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 22.02.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import UIKit

class AuditSpaceTableViewCell: UITableViewCell {

    private var heightConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
    }

    public func setupHeight(_ height: CGFloat) {
        if let constraint = self.heightConstraint {
            self.removeConstraint(constraint)
        }

        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1.0,
                                            constant: height)
        self.addConstraint(constraint)
        self.heightConstraint = constraint
    }
}

extension AuditSpaceTableViewCell: AuditQuestionTableViewCellProtocol {
    func setup(with auditQuestion: AuditQuestion) { }
}

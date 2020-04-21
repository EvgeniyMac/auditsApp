//
//  AuditTitleTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 19.02.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import UIKit

class AuditTitleTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = AppStyle.Color.custom(hex: 0xEEEEEE)
        self.contentView.backgroundColor = AppStyle.Color.custom(hex: 0xEEEEEE)

        [self.titleLabel, self.subtitleLabel].forEach { (label) in
            label?.numberOfLines = 0
        }

        self.titleLabel.textColor = AppStyle.Color.textSelected
        self.titleLabel.font = AppStyle.Font.medium(18)

        self.subtitleLabel.textColor = AppStyle.Color.darkGray
        self.subtitleLabel.font = AppStyle.Font.regular(16)
    }    
}

extension AuditTitleTableViewCell: AuditQuestionTableViewCellProtocol {
    func setup(with auditQuestion: AuditQuestion) {
        self.titleLabel.text = auditQuestion.questionText
        self.subtitleLabel.text = auditQuestion.description
    }
}

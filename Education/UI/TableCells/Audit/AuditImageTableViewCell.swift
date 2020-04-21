//
//  AuditImageTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 22.02.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import UIKit

class AuditImageTableViewCell: UITableViewCell {

    @IBOutlet weak var logoImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = AppStyle.Color.custom(hex: 0xEEEEEE)
    }
}

extension AuditImageTableViewCell: AuditQuestionTableViewCellProtocol {
    func setup(with auditQuestion: AuditQuestion) {
        let placeholder = UIImage(named: "audit.image.placeholder")
        self.logoImageView.image = placeholder
        if let url = auditQuestion.imageUrl {
            self.logoImageView.setImage(withUrl: url, placeholder: placeholder)
        }
    }
}

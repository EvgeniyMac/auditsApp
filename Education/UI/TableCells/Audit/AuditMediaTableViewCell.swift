//
//  AuditMediaTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 20.02.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import UIKit

class AuditMediaTableViewCell: UITableViewCell {

    var onPressAddPhotoButton: (() -> Void)?

    @IBOutlet weak var addPhotoContainer: UIView!
    @IBOutlet weak var addVideoContainer: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = AppStyle.Color.custom(hex: 0xEEEEEE)
        self.contentView.backgroundColor = AppStyle.Color.custom(hex: 0xEEEEEE)
    }

    // MARK: - Actions
    @IBAction private func didPressAddPhotoButton(_ sender: Any) {
        self.onPressAddPhotoButton?()
    }

    @IBAction private func didPressAddVideoButton(_ sender: Any) {
    }
}

extension AuditMediaTableViewCell: AuditQuestionTableViewCellProtocol {
    func setup(with auditQuestion: AuditQuestion) {
        self.addPhotoContainer.isHidden = !auditQuestion.canSendPhoto
        self.addVideoContainer.isHidden = !auditQuestion.canSendVideo
    }
}

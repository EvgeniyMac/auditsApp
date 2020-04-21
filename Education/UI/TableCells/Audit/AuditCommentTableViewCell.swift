//
//  AuditCommentTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 13.03.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import UIKit

class AuditCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var photoContainer: UIView!

    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var infoSeparatorImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.commentLabel.numberOfLines = Int.zero
        self.commentLabel.font = AppStyle.Font.regular(16)
        self.commentLabel.textColor = AppStyle.Color.textMainBrightened
        [self.authorLabel, self.dateLabel].forEach { (label) in
            label?.font = AppStyle.Font.regular(12)
            label?.textColor = AppStyle.Color.textMainBrightened
        }

        // changed hugging priority to handle multiple labels in a line
        self.dateLabel.setContentHuggingPriority(UILayoutPriority(100), for: .horizontal)

        self.infoSeparatorImageView.tintColor = AppStyle.Color.custom(hex: 0xA5A5A5)
    }
}

extension AuditCommentTableViewCell: AuditCommentTableViewCellProtocol {
    func setup(with comment: Comment?) {
        self.commentLabel.text = comment?.comment
        self.photoContainer.isHidden = true
        self.authorLabel.text = comment?.userName

        var dateFormatString: String?
        if !(comment?.dateTime?.isToday ?? false) {
            dateFormatString = "dd MMM"
        }
        self.dateLabel.text = comment?.dateTime?
            .dateTimeString(dateFormat: dateFormatString,
                            timeFormat: "HH:mm",
                            locale: Locale.current)
    }
}

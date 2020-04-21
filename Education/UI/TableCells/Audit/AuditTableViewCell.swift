//
//  AuditTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 19.02.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import UIKit

class AuditTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: MarginLabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var questionsLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.separatorView.backgroundColor = AppStyle.Color.separator
        self.titleLabel.font = AppStyle.Font.medium(18)
        self.titleLabel.textColor = AppStyle.Color.textMain

        [self.statusLabel,
         self.addressLabel,
         self.dateLabel,
         self.statsLabel,
         self.questionsLabel].forEach { (label) in
            label?.font = AppStyle.Font.regular(14)
            label?.textColor = AppStyle.Color.textSelected.withAlphaComponent(0.87)
        }
                
    }

    func setup(with audit: Audit) {
        self.titleLabel.text = audit.name
        self.statusLabel.backgroundColor = AppStyle.Color.backgroundMain
        self.statusLabel.text = AuditDisplayHelper.getStatusText(for: audit)
        
        self.statusLabel.backgroundColor = AuditDisplayHelper.getStatusBackgroundColor(for: audit)
        self.statusLabel.textColor = AuditDisplayHelper.getStatusTextColor(for: audit)
        self.statusLabel.layer.cornerRadius = AppStyle.CornerRadius.label
        self.statusLabel.layer.masksToBounds = true
        if self.statusLabel.backgroundColor == .clear {
          self.statusLabel.insets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 0)
        } else {
        self.statusLabel.insets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        }

        self.statusImageView.image = AuditDisplayHelper.getStatusImage(for: audit)
        if let address = audit.division {
            self.addressLabel.text = address + "   •   "
        } else {
            self.addressLabel.text = ""
        }
        
        guard let gainedWeight = audit.gainedWeight else { return }
        guard let questionWeightSum = audit.questionsWeightSum else { return }
        self.questionsLabel.text = ("\(gainedWeight)/\(questionWeightSum)")
        self.questionsLabel.textColor = AuditDisplayHelper.getStatusQuestionTextColor(for: audit)
        
        let dateFormat = audit.endDate?.isToday ?? false ? nil : "dd MMM"
        
        if let date = audit.endDate?
        .dateTimeString(dateFormat: dateFormat,
                        timeFormat: "HH:mm",
                        locale: Locale.current) {
            self.dateLabel.text = date + "   •   "
        } else {
            self.dateLabel.text = ""
        }
        
        if let checked = audit.statistic?.checkedCount,
            let total = audit.statistic?.checksTotalCount {
            self.statsLabel.text = "\(checked)/\(total)   •   "
        } else {
            self.statsLabel.text = nil
        }
    }

}

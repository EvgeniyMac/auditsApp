//
//  NewsItemHalfTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 21.12.2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class NewsItemHalfTableViewCell: UITableViewCell, NewsItemTableViewCellProtocol {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var categoryLabel: MarginLabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    @IBOutlet weak var supplementaryStackView: UIStackView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var separatorContainer: UIView!
    @IBOutlet weak var separatorImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.logoImageView.contentMode = .scaleAspectFill
        self.logoImageView.layer.cornerRadius = AppStyle.CornerRadius.default
        self.logoImageView.layer.masksToBounds = true

        self.categoryLabel.numberOfLines = Int.zero
        self.categoryLabel.textColor = AppStyle.Color.white
        self.categoryLabel.font = AppStyle.Font.regular(12)
        self.categoryLabel.backgroundColor = AppStyle.Color.purple
        self.categoryLabel.insets = UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 6)
        self.categoryLabel.layer.cornerRadius = AppStyle.CornerRadius.label
        self.categoryLabel.layer.masksToBounds = true

        self.titleLabel.numberOfLines = Int.zero
        self.titleLabel.textColor = AppStyle.Color.textSelected
        self.titleLabel.font = AppStyle.Font.medium(18)

        self.subtitleLabel.numberOfLines = Int.zero
        self.subtitleLabel.textColor = AppStyle.Color.textMainBrightened
        self.subtitleLabel.font = AppStyle.Font.regular(14)

        self.supplementaryStackView.spacing = 8
        [self.authorLabel, self.dateLabel].forEach { (label) in
            label?.numberOfLines = 1
            label?.textColor = AppStyle.Color.textMainBrightened
            label?.font = AppStyle.Font.regular(12)
        }
        self.authorLabel.setContentCompressionResistancePriority(.defaultLow,
                                                                 for: .horizontal)
        self.authorLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        self.separatorImageView.image = UIImage(named: "separator_dot")?
            .withRenderingMode(.alwaysTemplate)
        self.separatorImageView.tintColor = AppStyle.Color.textMainBrightened
    }

    // MARK: - NewsItemTableViewCellProtocol
    func setup(with newsItem: NewsItem) {
        self.logoImageView.image = UIImage(named: "news_placeholder.half")
        if let logoUrl = newsItem.logo {
            self.logoImageView.setImage(withUrl: logoUrl,
                                        placeholder: nil)
        }

        self.categoryLabel.text = newsItem.categoryName
        self.categoryLabel.isHidden = newsItem.categoryName?.isEmpty ?? true

        self.titleLabel.text = newsItem.name
        self.subtitleLabel.text = newsItem.description

        let dateString = newsItem.dateCreated?.dateTimeString(dateFormat: "dd MMM HH:mm",
                                                              timeFormat: nil,
                                                              locale: Locale.current)
        self.dateLabel.text = dateString
        let isDateUnavailable = dateString?.isEmpty ?? true
        self.dateLabel.isHidden = isDateUnavailable

        self.authorLabel.text = newsItem.authorName
        let isAuthorUnavailable = newsItem.authorName?.isEmpty ?? true
        self.authorLabel.isHidden = isAuthorUnavailable
        self.separatorContainer.isHidden = isDateUnavailable && isAuthorUnavailable
    }
}

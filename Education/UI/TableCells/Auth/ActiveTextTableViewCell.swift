//
//  ActiveTextTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 28/09/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit
import ActiveLabel

class ActiveTextTableViewCell: UITableViewCell {

    @IBOutlet weak var activeLabel: ActiveLabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.activeLabel.numberOfLines = .zero
    }

    // MARK: - Private
}

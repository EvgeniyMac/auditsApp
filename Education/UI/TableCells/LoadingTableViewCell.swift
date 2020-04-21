//
//  LoadingTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 26/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = UIColor.clear
        self.activityIndicator.color = AppStyle.Color.main
        self.activityIndicator.hidesWhenStopped = true

        if #available(iOS 13.0, *) {
            self.activityIndicator.style = .medium
        } else {
            self.activityIndicator.style = .white
        }
    }
}

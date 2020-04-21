//
//  ResultQuestionTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 10/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class ResultQuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var resultImageView: UIImageView!

    override func awakeFromNib() {
        self.questionLabel.font = AppStyle.Font.light(15)
        self.questionLabel.textColor = AppStyle.Color.textMain
    }
}

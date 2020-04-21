//
//  QuestionInitializer.swift
//  Education
//
//  Created by Andrey Medvedev on 21/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class QuestionInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var questionViewController: QuestionViewController!

    override func awakeFromNib() {

        let configurator = QuestionConfigurator()
        configurator.configureModuleForViewInput(viewInput: questionViewController)
    }

}

//
//  ResultInitializer.swift
//  Education
//
//  Created by Andrey Medvedev on 21/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class ResultInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var resultViewController: ResultViewController!

    override func awakeFromNib() {

        let configurator = ResultConfigurator()
        configurator.configureModuleForViewInput(viewInput: resultViewController)
    }

}

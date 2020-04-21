//
//  CourseInfoInitializer.swift
//  Education
//
//  Created by Andrey Medvedev on 20/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class CourseInfoInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var courseInfoViewController: CourseInfoViewController!

    override func awakeFromNib() {

        let configurator = CourseInfoConfigurator()
        configurator.configureModuleForViewInput(viewInput: courseInfoViewController)
    }

}

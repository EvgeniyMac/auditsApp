//
//  MaterialInitializer.swift
//  Education
//
//  Created by Andrey Medvedev on 20/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class MaterialInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var materialViewController: MaterialViewController!

    override func awakeFromNib() {

        let configurator = MaterialConfigurator()
        configurator.configureModuleForViewInput(viewInput: materialViewController)
    }

}

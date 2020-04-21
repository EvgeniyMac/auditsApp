//
//  SplashViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 16/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class SplashViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // requirement: need to show splash for 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // setting up a NavigationManager
            NavigationManager.shared.setup()
        }
    }

}

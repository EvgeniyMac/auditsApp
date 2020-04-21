//
//  CourseInfoConfigurator.swift
//  Education
//
//  Created by Andrey Medvedev on 20/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class CourseInfoConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? CourseInfoViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: CourseInfoViewController) {

        let router = CourseInfoRouter()

        let presenter = CourseInfoPresenter()
        presenter.view = viewController
        presenter.router = router

        viewController.output = presenter

        router.transitionHandler = viewController
    }

}

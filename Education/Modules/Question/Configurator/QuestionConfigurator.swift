//
//  QuestionConfigurator.swift
//  Education
//
//  Created by Andrey Medvedev on 21/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class QuestionConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? QuestionViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: QuestionViewController) {

        let router = QuestionRouter()

        let presenter = QuestionPresenter()
        presenter.view = viewController
        presenter.router = router

        viewController.output = presenter

        router.transitionHandler = viewController
    }

}

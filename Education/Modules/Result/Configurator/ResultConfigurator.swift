//
//  ResultConfigurator.swift
//  Education
//
//  Created by Andrey Medvedev on 21/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class ResultConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? ResultViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: ResultViewController) {

        let router = ResultRouter()

        let presenter = ResultPresenter()
        presenter.view = viewController
        presenter.router = router

        viewController.output = presenter

        router.transitionHandler = viewController
    }

}

//
//  MaterialConfigurator.swift
//  Education
//
//  Created by Andrey Medvedev on 20/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class MaterialConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? MaterialViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: MaterialViewController) {

        let router = MaterialRouter()

        let presenter = MaterialPresenter()
        presenter.view = viewController
        presenter.router = router

        viewController.output = presenter

        router.transitionHandler = viewController
    }

}

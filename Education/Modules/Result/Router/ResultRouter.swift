//
//  ResultRouter.swift
//  Education
//
//  Created by Andrey Medvedev on 21/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

protocol ResultRouterInput {
    func closeModule()
}

class ResultRouter: ResultRouterInput {
    weak var transitionHandler: TransitionHandlerProtocol!

    func closeModule() {
        self.transitionHandler.descendToViewController { (vc) -> Bool in
            return vc.isKind(of: CourseInfoViewController.self)
        }
    }
}

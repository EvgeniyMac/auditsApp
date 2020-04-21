//
//  QuestionRouter.swift
//  Education
//
//  Created by Andrey Medvedev on 21/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

protocol QuestionRouterInput {
    func openQuestion(atIndex index: Int, from questionnaire: Questionnaire?)
    func openResultScreen(with questionnaire: Questionnaire?)
    func closeTest()
}

class QuestionRouter: QuestionRouterInput {
    weak var transitionHandler: TransitionHandlerProtocol!

    // MARK: - QuestionRouterInput
    func closeTest() {
        self.transitionHandler.descendToViewController { (vc) -> Bool in
            return !vc.isKind(of: QuestionViewController.self)
        }
    }

    func openQuestion(atIndex index: Int, from questionnaire: Questionnaire?) {
        self.transitionHandler.openModule(storyboardName: "Courses",
                                          storyboardID: "QuestionViewControllerID",
                                          configurate: { (moduleInput) in
                                            if let moduleInput = moduleInput as? QuestionModuleInput {
                                                moduleInput.configureWith(questionnaire: questionnaire,
                                                                          questionIndex: index)
                                            }
        },
                                          isFromLeftAnimation: nil)
    }

    func openResultScreen(with questionnaire: Questionnaire?) {
        self.transitionHandler.openModule(segueIdentifier: "toResultViewController",
                                          configurate: { (moduleInput) in
                                            if let moduleInput = moduleInput as? ResultModuleInput {
                                                moduleInput.configureWith(questionnaire: questionnaire,
                                                                          course: nil)
                                            }
        })
    }
}

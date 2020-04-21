//
//  MaterialRouter.swift
//  Education
//
//  Created by Andrey Medvedev on 21/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

protocol MaterialRouterInput {
    func openQuestions(using questionnaire: Questionnaire)
    func closeModule()
    func closeModulesStack()
}

class MaterialRouter: MaterialRouterInput {

    weak var transitionHandler: TransitionHandlerProtocol!

    func openQuestions(using questionnaire: Questionnaire) {
        self.transitionHandler.openModule(segueIdentifier: "toQuestionViewController",
                                          configurate: { (moduleInput) in
                                            if let moduleInput = moduleInput as? QuestionModuleInput {
                                                moduleInput.configureWith(questionnaire: questionnaire,
                                                                          questionIndex: 0)
                                            }
        })
    }

    func closeModule() {
        self.transitionHandler.closeModule()
    }

    func closeModulesStack() {
        self.transitionHandler.closeModulesStack()
    }
}

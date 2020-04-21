//
//  ResultPresenter.swift
//  Education
//
//  Created by Andrey Medvedev on 21/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

protocol ResultModuleInput: ModuleInput {
    func configureWith(questionnaire: Questionnaire?, course: Course?)
}

class ResultPresenter: ResultModuleInput, ResultViewOutput {

    weak var view: ResultViewInput!
    var router: ResultRouterInput!

    private var questionnaire: Questionnaire?
    private var course: Course?

    // MARK: - ResultModuleInput
    func configureWith(questionnaire: Questionnaire?, course: Course?) {
        self.questionnaire = questionnaire
        self.course = course
        QuestionnaireManager.shared.setQuestionnaire(questionnaire)

        self.view.configureWith(questionnaire: questionnaire, course: course)
    }

    // MARK: - ResultViewOutput
    func viewIsReady() {

        if let questionnaire = questionnaire {
            sendAnswers(from: questionnaire)
        }
    }

    func shouldMoveBack() {
        self.router.closeModule()

        if let questionnaire = questionnaire,
            questionnaire.isTestPassed() {
                NotificationCenter.default.post(name: .DidPassTest,
                                                object: self.questionnaire?.material)
        }
    }

    // MARK: - Private
    private func sendAnswers(from questionnaire: Questionnaire) {
        self.view.showProgressIndicator()
        MaterialsService.saveAnswers(questionnaire: questionnaire,
                                     success: { result in
                                        self.view.hideProgressIndicator()
                                        self.view.configureWith(courseResult: result)
        },
                                     failure: { (error) in
                                        let onRetry: (() -> Void) = { [weak self] in
                                            self?.sendAnswers(from: questionnaire)
                                        }

                                        self.view.hideProgressIndicator()
                                        self.view.showError(error,
                                                            onRetry: onRetry,
                                                            onDismiss: nil)
        })
    }
}

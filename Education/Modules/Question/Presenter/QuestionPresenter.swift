//
//  QuestionPresenter.swift
//  Education
//
//  Created by Andrey Medvedev on 21/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

protocol QuestionModuleInput: ModuleInput {
    func configureWith(questionnaire: Questionnaire?, questionIndex: Int)
}

class QuestionPresenter: QuestionModuleInput, QuestionViewOutput {

    weak var view: QuestionViewInput!
    var router: QuestionRouterInput!

    var viewModel: QuestionViewModel? {
        didSet {
            self.view.configureWith(viewModel: self.viewModel)
        }
    }

    private var timer: TimerHandler?

    deinit {
        self.timer?.stopTimer()
    }

    // MARK: - QuestionModuleInput
    func configureWith(questionnaire: Questionnaire?, questionIndex: Int) {
        guard let questionnaire = questionnaire,
            questionIndex < questionnaire.questionItems.count else {
                self.view.showErrorMessage(forError: .incorrectInputData)
                return
        }

        let item = questionnaire.questionItems[questionIndex]
        self.viewModel = QuestionViewModel(withQuestionItem: item,
                                           atIndex: questionIndex,
                                           fromQuestionnaire: questionnaire)

        setupTimer(withDuration: item.question.duration)
    }

    // MARK: - QuestionViewOutput
    func shouldContinueTest(userAnswer: Questionnaire.UserAnswer,
                            forced: Bool) {
        guard let vm = self.viewModel else {
            self.view.showErrorMessage(withText: Localization.string("error.question_input_empty"))
            return
        }

        guard userAnswer.isValid() || forced else {
            self.view.showErrorMessage(withText: Localization.string("error.question_input_empty"))
            return
        }

        if vm.currentState == .answering {
            self.timer?.stopTimer()
            userAnswer.responseTime = Int(self.timer?.getSpentTime() ?? 0)
            vm.setUserAnswer(userAnswer)
            self.timer = nil
        }

        if let json = vm.item.toJSONString() {
            print("result JSON: \(json)")
        }

        if vm.shouldShowCorrectAnswers() {
            //showing answers
            vm.currentState = .reviewing
            self.viewModel = vm
        } else if vm.isLastQuestion() {
            shouldOpenResultScreen()
        } else {
            shouldOpenNextQuestion()
        }
    }

    func shouldOpenNextQuestion() {
        guard let vm = self.viewModel else { return }

        self.router.openQuestion(atIndex: vm.questionIndex + 1,
                                 from: vm.questionnaire)
    }

    func shouldOpenResultScreen() {
        guard let vm = self.viewModel else { return }

        self.router.openResultScreen(with: vm.questionnaire)
    }

    func shouldCloseTest() {
        self.timer?.stopTimer()
        self.router.closeTest()
    }

    // MARK: - Private
    private func setupTimer(withDuration: TimeInterval) {
        let duration = (withDuration > TimeInterval.zero) ? withDuration : nil
        self.timer = TimerHandler(withDuration: duration)

        self.timer?.onChange = { [weak self] (secondsSpent, secondsLeft) in
            print("TIMER: - Spent:\(secondsSpent)")
            if let timeLeft = secondsLeft {
                self?.view.updateAppearanceForTimer(secondsLeft: timeLeft)
            }
        }
        self.timer?.onFinish = { [weak self] in
            print("TIMER: - Time is over")
            self?.view.didReceiveAnsweringTimeout()
        }

        self.timer?.startTimer()
        print("TIMER: - START")
    }
}

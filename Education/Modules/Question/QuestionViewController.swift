//
//  QuestionViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 28/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

protocol QuestionViewOutput {
    func shouldContinueTest(userAnswer: Questionnaire.UserAnswer,
                            forced: Bool)
    func shouldCloseTest()
}

protocol QuestionViewInput: class {
    func showProgressIndicator()
    func hideProgressIndicator()
    func showErrorMessage(withText: String)
    func showError(_ error: NetworkError,
                   onRetry: (() -> Void)?,
                   onDismiss: (() -> Void)?)
    func showErrorMessage(forError error: NetworkError)

    func configureWith(viewModel: QuestionViewModel?)
    func updateAppearanceForTimer(secondsLeft: TimeInterval)
    func didReceiveAnsweringTimeout()
}

class QuestionViewController: BaseViewController, QuestionViewInput, KeyboardObserver {

    enum QuestionButtonState {
        case disabled
        case enabledUnknown
        case enabledCorrect
        case enabledIncorrect
        case hidden
    }

    var output: QuestionViewOutput!

    @IBOutlet weak var questionContainerView: UIView!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var proceedContainer: UIView!
    @IBOutlet weak var proceedContainerSeparator: UIView!
    @IBOutlet weak var proceedButton: CustomButton!
    
    @IBOutlet weak var resultContainer: UIView!
    @IBOutlet weak var resultTitleLabel: UILabel!
    @IBOutlet weak var resultDescriptionLabel: UILabel!

    var viewModel: QuestionViewModel?
    var userAnswer = Questionnaire.UserAnswer()

    var inputTextField: UITextField?

    // WORKAROUND: variable to store image
    var questionImage: UIImage?

    private var questionItemController: BaseQuestionItemViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let totalCount = self.viewModel?.getMaterialQuestionsCount(),
            let currentIndex = self.viewModel?.questionIndex {
            let questionText = Localization.string("question.question_title")
            self.title = "\(questionText): \(currentIndex + 1)/\(totalCount)"
        }

        configureUI()
        configureTable()
        configureQuestionContainer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let proceedContainerHeight = self.proceedContainer.frame.height
        updateTableInset(bottomInset: proceedContainerHeight)
        subscribeToKeyboardNotifications { [weak self] (offset) in
            self?.updateTableInset(bottomInset: offset)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        unsubscribeFromKeyboardNotifications()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let bottomInset = self.proceedContainer.frame.height
        updateTableInset(bottomInset: bottomInset)
    }

    override func shouldHideTabBar() -> Bool {
        return true
    }

    override func shouldMoveBack() {
        let alertText = Localization.string("alert.test_interrupt.text")
        let actionText = Localization.string("alert.test_interrupt.action")
        let alert = UIAlertController(title: Localization.string("common.warning"),
                                      message: alertText,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionText,
                                      style: .default,
                                      color: AppStyle.Color.red,
                                      handler: { [weak self] (_) in
                                        self?.output.shouldCloseTest()
        }))
        alert.addAction(UIAlertAction(title: Localization.string("common.cancel"),
                                      style: .cancel,
                                      color: AppStyle.Color.textMain,
                                      handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - QuestionViewInput
    func configureWith(viewModel: QuestionViewModel?) {
        self.viewModel = viewModel

        guard self.isViewLoaded else { return }

        configureUI()
        configureQuestionContainer()
    }

    func updateAppearanceForTimer(secondsLeft: TimeInterval) {
        if secondsLeft >= 0 {
            self.navigationItem.rightBarButtonItem = createTimerBarItem(duration: secondsLeft)
        }
    }

    func didReceiveAnsweringTimeout() {
        self.output.shouldContinueTest(userAnswer: self.userAnswer, forced: true)
    }

    // MARK: - Actions
    @IBAction private func didPressProceedButton(_ sender: Any) {
        self.view.endEditing(true)

        self.output.shouldContinueTest(userAnswer: self.userAnswer,
                                       forced: self.viewModel?.currentState == .reviewing)
    }

    @objc func didChangeTextFieldValue(_ sender: UITextField) {
        self.userAnswer.value = sender.text
    }

    // MARK: - Private
    private func configureUI() {
        if #available(iOS 11, *) {}
        else {
            let topInset = self.navigationController?.navigationBar.frame.height
            self.tableView.contentInset.top = topInset ?? 0
            let bottomInset = self.tabBarController?.tabBar.frame.height
            self.tableView.contentInset.bottom = bottomInset ?? 0
        }

        configureProceedContainer()
        updateProceedContainer()
        configureProceedButton()
    }

    private func configureProceedContainer() {
        let separatorColor = AppStyle.Color.custom(hex: 0xDDDDDD)
        self.proceedContainerSeparator.backgroundColor = separatorColor
        AppStyle.setupShadow(forContainer: self.proceedContainer)

        let textColor = AppStyle.Color.textMain.withAlphaComponent(0.64)
        self.resultTitleLabel.text = nil
        self.resultTitleLabel.textColor = textColor
        self.resultTitleLabel.font = AppStyle.Font.medium(20)
        self.resultDescriptionLabel.text = nil
        self.resultDescriptionLabel.textColor = textColor
        self.resultDescriptionLabel.font = AppStyle.Font.regular(16)
    }

    func updateProceedContainer() {
        guard let vm = self.viewModel else { return }

        switch vm.currentState {
        case .answering:
            self.resultTitleLabel.text = nil
            self.resultTitleLabel.textColor = AppStyle.Color.green

            self.proceedContainer.backgroundColor = AppStyle.Color.white
            self.proceedButton.backgroundColor = AppStyle.Color.buttonDisabled
            self.proceedButton.isEnabled = false

            self.resultDescriptionLabel.text = nil
            self.resultContainer.isHidden = true
        case .reviewing:
            if vm.item.answer?.isCorrect ?? false {
                self.resultTitleLabel.text = Localization.string("question.answer_correct")
                self.resultTitleLabel.textColor = AppStyle.Color.green

                self.proceedContainer.backgroundColor = AppStyle.Color.backgroundCorrect
                self.proceedButton.backgroundColor = AppStyle.Color.green
                self.proceedButton.isEnabled = true
            } else {
                self.resultTitleLabel.text = Localization.string("question.answer_incorrect")
                self.resultTitleLabel.textColor = AppStyle.Color.red

                self.proceedContainer.backgroundColor = AppStyle.Color.backgroundIncorrect
                self.proceedButton.backgroundColor = AppStyle.Color.red
                self.proceedButton.isEnabled = true
            }

            if vm.questionnaire.material.showCorrect == .every {
                self.resultDescriptionLabel.text = vm.item.question.explanation
                self.resultContainer.isHidden = false
            } else {
                self.resultDescriptionLabel.text = nil
                self.resultContainer.isHidden = true
            }
        }

//        if let userAnswer = vm.item.answer,
//            vm.questionnaire.material.showCorrect == .every {
//            self.resultContainer.isHidden = false
//
//            if userAnswer.isCorrect {
//                self.resultTitleLabel.text = Localization.string("question.answer_correct")
//                self.resultTitleLabel.textColor = AppStyle.Color.green
//                self.proceedContainer.backgroundColor = AppStyle.Color.backgroundCorrect
//                self.proceedButton.backgroundColor = AppStyle.Color.green
//            } else {
//                self.resultTitleLabel.text = Localization.string("question.answer_incorrect")
//                self.resultTitleLabel.textColor = AppStyle.Color.red
//                self.proceedContainer.backgroundColor = AppStyle.Color.backgroundIncorrect
//                self.proceedButton.backgroundColor = AppStyle.Color.red
//            }
//            self.resultDescriptionLabel.text = vm.item.question.explanation
//        } else if vm.currentState == .reviewing {
//            self.resultContainer.isHidden = false
//        } else {
//            self.resultContainer.isHidden = true
//        }
    }

    private func configureProceedButton() {
        guard let vm = self.viewModel else { return }

        var buttonTitleKey: String
        if vm.shouldShowCorrectAnswers() {
            buttonTitleKey = "question.answer_button"
        } else if vm.isLastQuestion() {
            buttonTitleKey = "question.finish_button"
        } else {
            buttonTitleKey = "question.next_question_button"
        }

        let buttonTitle = Localization.string(buttonTitleKey)
        self.proceedButton.setTitle(buttonTitle, for: .normal)
    }

    func setupProceedButton(withState state: QuestionButtonState) {
        switch state {
        case .enabledCorrect,
             .enabledUnknown:
//            self.proceedContainer.isHidden = false
            self.proceedButton.backgroundColor = AppStyle.Color.green
            self.proceedButton.isEnabled = true
        case .enabledIncorrect:
            self.proceedButton.backgroundColor = AppStyle.Color.red
            self.proceedButton.isEnabled = true
        case .disabled:
//            self.proceedContainer.isHidden = false
            self.proceedButton.backgroundColor = AppStyle.Color.buttonDisabled
            self.proceedButton.isEnabled = false
        case .hidden:
//            self.proceedContainer.isHidden = true
            self.proceedButton.isEnabled = false
        }
    }

    private func configureQuestionContainer() {
        guard let vm = viewModel,
            let questionType = vm.item.question.type else {
                return
        }

        switch questionType {
        case .sequence:
            if self.questionItemController == nil {
                let nibName = "SequenceQuestionItemViewController"
                let vc = SequenceQuestionItemViewController(nibName: nibName, bundle: nil)
                vc.onCompletion = { [weak self] (result) in
                    if let result = result {
                        self?.userAnswer = result
                        self?.setupProceedButton(withState: .enabledUnknown)
                    } else {
                        self?.setupProceedButton(withState: .disabled)
                    }
                }
                self.questionItemController = vc
                self.addChildViewController(vc, to: self.questionContainerView)
            }
            self.view.bringSubviewToFront(self.questionContainerView)

            if vm.currentState == .reviewing {
                self.questionItemController?.updateState(readonly: true)
            } else {
                self.questionItemController?.setupWith(item: vm.item,
                                                       readonly: false)
            }
        case .conformity,
             .conformityImage:
            if self.questionItemController == nil {
                let nibName = "ConformityQuestionItemViewController"
                let vc = ConformityQuestionItemViewController(nibName: nibName, bundle: nil)
                vc.onCompletion = { [weak self] (result) in
                    if let result = result {
                        self?.userAnswer = result
                        self?.setupProceedButton(withState: .enabledUnknown)
                    } else {
                        self?.setupProceedButton(withState: .disabled)
                    }
                }
                self.questionItemController = vc
                self.addChildViewController(vc, to: self.questionContainerView)
            }
            self.view.bringSubviewToFront(self.questionContainerView)

            if vm.currentState == .reviewing {
                self.questionItemController?.updateState(readonly: true)
            } else {
                self.questionItemController?.setupWith(item: vm.item,
                                                       readonly: false)
            }
        default:
            self.tableView.reloadData()
//            self.view.bringSubviewToFront(self.tableView)
        }
    }

    private func configureTable() {
        [TextTableViewCell.self,
         AnswerImageTableViewCell.self,
         AnswerTextTableViewCell.self,
         AnswerBoolTableViewCell.self,
         AnswerOptionTableViewCell.self,
         AnswerSequenceTableViewCell.self,
         AnswerResultTableViewCell.self,
         AnswerTilesTableViewCell.self,
         TextCloudTableViewCell.self]
            .forEach { [unowned self] (type) in
                type.registerNib(at: self.tableView)
        }
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 60
    }

    private func updateTableInset(bottomInset: CGFloat) {
        let currentBottomInset = self.tableView.contentInset.bottom
        if currentBottomInset != bottomInset {
            self.tableView.contentInset.bottom = max(currentBottomInset, bottomInset)
        }
    }

    private func createTimerBarItem(duration: TimeInterval) -> UIBarButtonItem {
        let timerLabel = UILabel()
        timerLabel.font = AppStyle.Font.medium(16)
        timerLabel.textColor = AppStyle.Color.textMain
        timerLabel.text = duration.readableString()
        if #available(iOS 11.0, *) {
        } else {
            timerLabel.textAlignment = .right
            timerLabel.frame.size = timerLabel.approximateSize()
        }
        return UIBarButtonItem(customView: timerLabel)
    }
}

extension QuestionViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

//
//  QuestionViewController+UITableViewDelegate.swift
//  Education
//
//  Created by Andrey Medvedev on 05/05/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

extension QuestionViewController: UITableViewDelegate {
}

extension QuestionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return (self.viewModel != nil) ? 1 : 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model = self.viewModel else {
            return 0
        }
        return model.rows.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let vm = self.viewModel,
            vm.rows.count > indexPath.row else {
                fatalError("Incorrect view model at Question table (position: \(indexPath)")
        }

        let row = vm.rows[indexPath.row]
        switch row {
        case .image(let url):
            // max height is 3/4 of width according to request 10788
            let maxHeight = tableView.frame.width * 0.75
            if let questionImage = questionImage {
                return QuestionStyleManager.createImageCell(tableView: tableView,
                                                            indexPath: indexPath,
                                                            image: questionImage,
                                                            maxHeight: maxHeight)
            } else {
                return QuestionStyleManager.createImageCell(tableView: tableView,
                                                            indexPath: indexPath,
                                                            imageUrl: url,
                                                            maxHeight: maxHeight,
                                                            onLoadImage: { (img) in
                                                                self.questionImage = img
                })
            }
        case .question(let text):
            let cell = QuestionStyleManager.createTextCell(tableView: tableView,
                                                           indexPath: indexPath)
            cell.contentLabel?.text = text
            cell.contentLabel?.font = AppStyle.Font.medium(20)
            cell.contentLabel?.textColor = AppStyle.Color.textMain
            cell.insets = UIEdgeInsets(top: 20, left: 18, bottom: 24, right: 18)
            return cell
        case .hint(let text):
            let cell = QuestionStyleManager.createTextCell(tableView: tableView,
                                                           indexPath: indexPath)
            cell.contentLabel?.text = text
            cell.contentLabel?.font = AppStyle.Font.light(15)
            cell.contentLabel?.textColor = AppStyle.Color.textMain
            cell.insets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
            return cell
        case .inputNumber(let userAnswer):
            let cell = QuestionStyleManager.createAnswerTextCell(tableView: tableView,
                                                                 indexPath: indexPath)

            self.inputTextField = cell.textField
            cell.textField.keyboardType = .decimalPad
            cell.textField.placeholder = Localization.string("question.text_input.placeholder")
            cell.textField.addTarget(self,
                                     action: #selector(didChangeTextFieldValue(_:)),
                                     for: .editingChanged)
            cell.textField.addTarget(self,
                                     action: #selector(didChangeTextFieldValue(_:)),
                                     for: .editingDidEnd)

            if vm.currentState == .reviewing {
                cell.textField.isEnabled = false
                cell.textField.text = userAnswer?.value as? String
                cell.onChangeText = nil

                if (userAnswer?.isCorrect == true) {
                    setupProceedButton(withState: .enabledCorrect)
                } else {
                    setupProceedButton(withState: .enabledIncorrect)
                }

//                if userAnswer?.isCorrect == true {
//                    cell.resultImageView.image = AppStyle.Image.answerCorrect
//                } else {
//                    cell.resultImageView.image = AppStyle.Image.answerIncorrect
//                }
            } else {
                cell.onChangeText = { [weak self] (text) in
                    let enableButton = (!text.isEmpty) || (vm.currentState == .reviewing)
                    if enableButton {
                        var buttonState: QuestionButtonState = .enabledUnknown
                        if vm.currentState == .reviewing {
                            let isCorrect = (self?.userAnswer.isCorrect == true)
                            buttonState = isCorrect ? .enabledCorrect : .enabledIncorrect
                        }
                        self?.setupProceedButton(withState: buttonState)
                    } else {
                        self?.setupProceedButton(withState: .disabled)
                    }
                }
            }
            return cell
        case .inputText(let userAnswer):
            let cell = QuestionStyleManager.createAnswerTextCell(tableView: tableView,
                                                                 indexPath: indexPath)

            self.inputTextField = cell.textField
            cell.textField.keyboardType = .default
            cell.textField.placeholder = Localization.string("question.text_input.placeholder")
            cell.textField.addTarget(self,
                                     action: #selector(didChangeTextFieldValue(_:)),
                                     for: .editingChanged)
            cell.textField.addTarget(self,
                                     action: #selector(didChangeTextFieldValue(_:)),
                                     for: .editingDidEnd)

            if vm.currentState == .reviewing {
                cell.textField.isEnabled = false
                cell.textField.text = userAnswer?.value as? String
                cell.onChangeText = nil

                let isCorrect = (userAnswer?.isCorrect == true)
                let buttonState: QuestionButtonState = isCorrect ? .enabledCorrect : .enabledIncorrect
                setupProceedButton(withState: buttonState)

//                if userAnswer?.isCorrect == true {
//                    cell.resultImageView.image = AppStyle.Image.answerCorrect
//                } else {
//                    cell.resultImageView.image = AppStyle.Image.answerIncorrect
//                }
            } else {
                cell.onChangeText = { [weak self] (text) in
                    let enableButton = (!text.isEmpty) || (vm.currentState == .reviewing)
                    if enableButton {
                        var buttonState: QuestionButtonState = .enabledUnknown
                        if vm.currentState == .reviewing {
                            let isCorrect = (self?.userAnswer.isCorrect == true)
                            buttonState = isCorrect ? .enabledCorrect : .enabledIncorrect
                        }
                        self?.setupProceedButton(withState: buttonState)
                    } else {
                        self?.setupProceedButton(withState: .disabled)
                    }
                }
            }
            return cell
        case .optionsBool(let answers, let userAnswerString):
            let cell = QuestionStyleManager.createAnswerOptionCell(tableView: tableView,
                                                                   indexPath: indexPath)

            var predefinedState: [String]?
            if let answerId = userAnswerString {
                predefinedState = [answerId]
            }
            cell.update(withOptions: answers,
                        type: .single,
                        isEditable: (vm.currentState == .answering),
                        predefinedState: predefinedState)

            cell.onChangeState = { [weak self] (state) in
                print("state=\(state)")
                guard vm.currentState == .answering else {
                    return
                }

                self?.userAnswer.value = state.first
                if let answer = self?.userAnswer {
                    self?.viewModel?.setUserAnswer(answer)
                }

                let enableButton = (!state.isEmpty) || (vm.currentState == .reviewing)
                if enableButton {
                    var buttonState: QuestionButtonState = .enabledUnknown
                    if vm.currentState == .reviewing {
                        let isCorrect = (self?.userAnswer.isCorrect == true)
                        buttonState = isCorrect ? .enabledCorrect : .enabledIncorrect
                    }
                    self?.setupProceedButton(withState: buttonState)
                } else {
                    self?.setupProceedButton(withState: .disabled)
                }
            }
            return cell
        case .optionOne(let answers, let userAnswerString):
            let cell = QuestionStyleManager.createAnswerOptionCell(tableView: tableView,
                                                                   indexPath: indexPath)

            var predefinedState: [String]?
            if let userAnswerString = userAnswerString {
                predefinedState = [userAnswerString]
            }
            cell.update(withOptions: answers,
                        type: .single,
                        isEditable: (vm.currentState == .answering),
                        predefinedState: predefinedState)

            cell.onChangeState = { [weak self] (state) in
                print("state=\(state)")
                guard vm.currentState == .answering else {
                    return
                }

                self?.userAnswer.value = state.first
                if let answer = self?.userAnswer {
                    self?.viewModel?.setUserAnswer(answer)
                }

                let enableButton = (!state.isEmpty) || (vm.currentState == .reviewing)
                if enableButton {
                    var buttonState: QuestionButtonState = .enabledUnknown
                    if vm.currentState == .reviewing {
                        let isCorrect = (self?.userAnswer.isCorrect == true)
                        buttonState = isCorrect ? .enabledCorrect : .enabledIncorrect
                    }
                    self?.setupProceedButton(withState: buttonState)
                } else {
                    self?.setupProceedButton(withState: .disabled)
                }
            }
            return cell
        case .optionOneImage(let answers, let userAnswerString):
            let cell = QuestionStyleManager.createAnswerTilesCell(tableView: tableView,
                                                                  indexPath: indexPath)

            var predefinedState: [String]?
            if let userAnswerString = userAnswerString {
                predefinedState = [userAnswerString]
            }
            cell.update(withAnswers: answers,
                        type: .single,
                        isEditable: (vm.currentState == .answering),
                        predefinedState: predefinedState)

            cell.onChangeState = { [weak self] (state) in
                print("state=\(state)")
                guard vm.currentState == .answering else {
                    return
                }

                self?.userAnswer.value = state.first
                if let answer = self?.userAnswer {
                    self?.viewModel?.setUserAnswer(answer)
                }

                let enableButton = (!state.isEmpty) || (vm.currentState == .reviewing)
                if enableButton {
                    var buttonState: QuestionButtonState = .enabledUnknown
                    if vm.currentState == .reviewing {
                        let isCorrect = (self?.userAnswer.isCorrect == true)
                        buttonState = isCorrect ? .enabledCorrect : .enabledIncorrect
                    }
                    self?.setupProceedButton(withState: buttonState)
                } else {
                    self?.setupProceedButton(withState: .disabled)
                }
            }
            return cell
        case .optionSome(let answers, let userAnswerStrings):
            let cell = QuestionStyleManager.createAnswerOptionCell(tableView: tableView,
                                                                   indexPath: indexPath)

            cell.update(withOptions: answers,
                        type: .multiple,
                        isEditable: (vm.currentState == .answering),
                        predefinedState: userAnswerStrings)

            cell.onChangeState = {[weak self] (state) in
                print("state=\(state)")
                self?.userAnswer.valueArray = state
                if let answer = self?.userAnswer {
                    self?.viewModel?.setUserAnswer(answer)
                }

                let enableButton = (!state.isEmpty) || (vm.currentState == .reviewing)
                if enableButton {
                    var buttonState: QuestionButtonState = .enabledUnknown
                    if vm.currentState == .reviewing {
                        let isCorrect = (self?.userAnswer.isCorrect == true)
                        buttonState = isCorrect ? .enabledCorrect : .enabledIncorrect
                    }
                    self?.setupProceedButton(withState: buttonState)
                } else {
                    self?.setupProceedButton(withState: .disabled)
                }
            }
            return cell
        case .optionSomeImages(let answers, let userAnswerStrings):
            let cell = QuestionStyleManager.createAnswerTilesCell(tableView: tableView,
                                                                  indexPath: indexPath)

            cell.update(withAnswers: answers,
                        type: .multiple,
                        isEditable: (vm.currentState == .answering),
                        predefinedState: userAnswerStrings)

            cell.onChangeState = {[weak self] (state) in
                print("state=\(state)")
                self?.userAnswer.valueArray = state
                if let answer = self?.userAnswer {
                    self?.viewModel?.setUserAnswer(answer)
                }

                let enableButton = (!state.isEmpty) || (vm.currentState == .reviewing)
                if enableButton {
                    var buttonState: QuestionButtonState = .enabledUnknown
                    if vm.currentState == .reviewing {
                        let isCorrect = (self?.userAnswer.isCorrect == true)
                        buttonState = isCorrect ? .enabledCorrect : .enabledIncorrect
                    }
                    self?.setupProceedButton(withState: buttonState)
                } else {
                    self?.setupProceedButton(withState: .disabled)
                }
            }
            return cell
        case .conformity(let keys, let values, let hint, let userAnswer):
            let cell = QuestionStyleManager.createAnswerSequenceCell(tableView: tableView,
                                                                     indexPath: indexPath)

            if vm.currentState == .reviewing {
                userAnswer.markEmptyValuesAsIncorrect()
            }
            cell.matchingSeparator = " - "
            cell.update(withKeys: keys,
                        values: values,
                        isEditable: (vm.currentState == .answering),
                        predefinedState: userAnswer)
            cell.onChangeState = { [weak self] (state) in
                print("state=\(state)")
                self?.userAnswer.valueDictionary = state.toDictionary() ?? [:]
                if let answer = self?.userAnswer {
                    self?.viewModel?.setUserAnswer(answer)
                }

                let enableButton = state.isConformityCompleted() || (vm.currentState == .reviewing)
                if enableButton {
                    var buttonState: QuestionButtonState = .enabledUnknown
                    if vm.currentState == .reviewing {
                        let isCorrect = (self?.userAnswer.isCorrect == true)
                        buttonState = isCorrect ? .enabledCorrect : .enabledIncorrect
                    }
                    self?.setupProceedButton(withState: buttonState)
                } else {
                    self?.setupProceedButton(withState: .disabled)
                }
            }
            cell.commentLabel.text = hint
            return cell
        case .sequence(let keys, let values, let hint, let userAnswer):
            let cell = QuestionStyleManager.createAnswerSequenceCell(tableView: tableView,
                                                                     indexPath: indexPath)
            cell.matchingSeparator = " "
            cell.update(withKeys: keys,
                        values: values,
                        isEditable: (vm.currentState == .answering),
                        predefinedState: userAnswer)
            cell.onChangeState = { [weak self] (state) in
                print("state=\(state)")
                self?.userAnswer.valueArray = state.toArray() ?? []
                if let answer = self?.userAnswer {
                    self?.viewModel?.setUserAnswer(answer)
                }

                let enableButton = state.isConformityCompleted() || (vm.currentState == .reviewing)
                if enableButton {
                    var buttonState: QuestionButtonState = .enabledUnknown
                    if vm.currentState == .reviewing {
                        let isCorrect = (self?.userAnswer.isCorrect == true)
                        buttonState = isCorrect ? .enabledCorrect : .enabledIncorrect
                    }
                    self?.setupProceedButton(withState: buttonState)
                } else {
                    self?.setupProceedButton(withState: .disabled)
                }
            }
            cell.commentLabel.text = hint
            return cell
        case .resultImage(let isSuccess):
            let image = isSuccess ? AppStyle.Image.answerCorrect : AppStyle.Image.answerIncorrect
            return QuestionStyleManager.createResultImageCell(tableView: tableView,
                                                              indexPath: indexPath,
                                                              image: image)
        }
    }
}

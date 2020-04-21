//
//  QuestionViewModel.swift
//  Education
//
//  Created by Andrey Medvedev on 28/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

class QuestionViewModel {
    public enum QuestionTableRowType {
        case image(url: URL)
        case question(text: String)
        case hint(text: String)
        case inputNumber(userAnswer: Questionnaire.UserAnswer?)
        case inputText(userAnswer: Questionnaire.UserAnswer?)
        case optionOne(answer: [Answer], userAnswer: String?)
        case optionOneImage(answer: [Answer], userAnswer: String?)
        case optionSome(answer: [Answer], userAnswer: [String]?)
        case optionSomeImages(answer: [Answer], userAnswer: [String]?)
        case optionsBool(answer: [Answer], userAnswer: String?)
        case conformity(keys: [String], values: [String], hint: String, userAnswer: ConformityMatchState)
        case sequence(keys: [String], values: [String], hint: String, userAnswer: ConformityMatchState)
        case resultImage(isSuccess: Bool)
    }

    public var currentState = ScreenState.answering
    public enum ScreenState {
        case answering
        case reviewing
    }

    public var questionnaire: Questionnaire
    public var questionIndex: Int = 0
    public var item: Questionnaire.Item

    public var rows: [QuestionTableRowType]

    init(withQuestionItem object: Questionnaire.Item,
         atIndex index: Int,
         fromQuestionnaire questionnaire: Questionnaire) {
        self.questionnaire = questionnaire
        self.questionIndex = index
        self.item = object
        self.rows = QuestionViewModel.getRows(for: object)
    }

    public func setUserAnswer(_ answer: Questionnaire.UserAnswer) {
        self.item.answer = answer
        updateRows(usingItem: self.item)
    }

    private func updateRows(usingItem: Questionnaire.Item) {
        self.rows = QuestionViewModel.getRows(for: usingItem)
    }

    private static func getRows(for item: Questionnaire.Item) -> [QuestionTableRowType] {
        guard let type = item.question.type else {
            return []
        }

        var rows = [QuestionTableRowType]()
        if let imageUrl = item.question.imageUrl {
            rows.append(.image(url: imageUrl))
        }
        if let questionText = item.question.questionText {
            rows.append(.question(text: questionText))
        }

        switch type {
        case .trueFalse:
            guard let answers = item.question.answers else { break }
            rows.append(.optionsBool(answer: answers,
                                     userAnswer: item.answer?.value as? String))
        case .number:
//            rows.append(.hint(text: Localization.string("question.question_number_hint")))
            rows.append(.inputNumber(userAnswer: item.answer))
        case .exactMatch:
//            rows.append(.hint(text: Localization.string("question.question_exact_match_hint")))
            rows.append(.inputText(userAnswer: item.answer))
        case .oneCorrect:
            guard let answers = item.question.answers else { break }
//            rows.append(.hint(text: Localization.string("question.question_one_correct_hint")))
            rows.append(.optionOne(answer: answers,
                                   userAnswer: item.answer?.value as? String))
        case .oneCorrectImage:
            guard let answers = item.question.answers else { break }
            rows.append(.optionOneImage(answer: answers,
                                        userAnswer: item.answer?.value as? String))
        case .someCorrect:
            guard let answers = item.question.answers else { break }
            rows.append(.hint(text: Localization.string("question.question_some_correct_hint")))
            rows.append(.optionSome(answer: answers,
                                    userAnswer: item.answer?.valueArray))
        case .someCorrectImages:
            guard let answers = item.question.answers else { break }
            rows.append(.optionSomeImages(answer: answers,
                                          userAnswer: item.answer?.valueArray))
        case .sequence:
            guard let data = item.question.answers?.compactMap({ (answer) -> String? in
                return answer.value
            }) else {
                break
            }

            let keys = (1...data.count).map({ "\($0)." })
            let state = ConformityMatchState.from(keys: keys,
                                                  array: item.answer?.valueArray,
                                                  answers: item.question.answers)
            let hint = Localization.string("question.question_sequence_hint")
            rows.append(.sequence(keys: keys,
                                  values: data.shuffled(),
                                  hint: hint,
                                  userAnswer: state))
//            if item.answer != nil {
//                var isSuccess = data.isEmpty
//                if let userArray = item.answer?.valueArray,
//                    data.count == userArray.count {
//                    isSuccess = zip(data, userArray).filter({ $0 != $1 }).isEmpty
//                }
//                rows.append(.resultImage(isSuccess: isSuccess))
//            }
        case .conformity,
             .conformityImage:
            guard let data = item.question.answers?.reduce([String : String](),
                                                           { (dict, answer) -> [String : String] in
                                                            var dict = dict
                                                            if let key = answer.key,
                                                                let value = answer.value {
                                                                dict[key] = value
                                                            }
                                                            return dict
            }) else {
                break
            }

            let keys = Array(data.keys)
            let values = Array(data.values)
            let hint = Localization.string("question.question_conformity_hint")
            let state = ConformityMatchState.from(keys: keys,
                                                  dictionary: item.answer?.valueDictionary,
                                                  answers: item.question.answers)
            rows.append(.conformity(keys: keys,
                                    values: values.shuffled(),
                                    hint: hint,
                                    userAnswer: state))
//            if let userAnswer = item.answer {
//                let isSuccess = data == userAnswer.valueDictionary
//                rows.append(.resultImage(isSuccess: isSuccess))
//            }
        }

//        if let userAnswer = item.answer,
//            !userAnswer.isCorrect,
//            let explanation = item.question.explanation {
//            rows.append(contentsOf: [
//                .hint(text: Localization.string("question.question_explanation")),
//                .hint(text: explanation)])
//        }

        return rows
    }

    public func getMaterialQuestionsCount() -> Int? {
        return self.questionnaire.material.questionsCount
    }

    public func shouldShowCorrectAnswers() -> Bool {
        guard let showCorrect = self.questionnaire.material.showCorrect else {
            return false
        }
        return (showCorrect == .every) && (self.currentState == .answering)
    }

    public func isLastQuestion() -> Bool {
        let questionsCount = self.questionnaire.questionItems.count
        return self.questionIndex >= questionsCount - 1
    }
}

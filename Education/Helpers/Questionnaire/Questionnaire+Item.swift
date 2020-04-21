//
//  Questionnaire+Item.swift
//  Education
//
//  Created by Andrey Medvedev on 13/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation
import ObjectMapper

extension Questionnaire {

    class Item: Mappable {
        let question: Question
        var answer: UserAnswer? {
            didSet {
                answer?.isCorrect = isAnswerCorrect()
            }
        }

        init(with question: Question) {
            self.question = question
        }

        required init?(map: Map) {
            self.question = Question(map: map)!
        }

        func mapping(map: Map) {
            guard answer?.isValid() ?? false else {
                return
            }

            question.identifier >>> map["question_id"]
            question.type >>> map["type"]
            answer?.responseTime >>> map["response_time"]

            if let type = question.type {
                switch type {
                case .number:
                    let answerString = answer?.value as? String
                    let updatedString = answerString?
                        .replacingOccurrences(of: ",",
                                              with: ".",
                                              options: .literal,
                                              range: nil)
                    updatedString >>> map["answer"]
                case .oneCorrect,
                     .exactMatch,
                     .oneCorrectImage,
                     .trueFalse:
                    answer?.value >>> map["answer"]
                case .someCorrect,
                     .sequence,
                     .someCorrectImages:
                    answer?.valueArray >>> map["answer"]
                case .conformity,
                     .conformityImage:
                    answer?.valueDictionary >>> map["answer"]
                }
            }
        }

        // MARK: - Private
        private func compareAnswerStrings(str1: String?, str2: String?) -> Bool {
            let s1 = str1?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            let s2 = str2?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            return s1 == s2
        }

        private func compareNumberString(string: String?, to mask: String?) -> Bool {
            guard let string = string,
                let mask = mask else {
                    return false
            }

            // WORKAROUND: workaround to handle a problem when a locale decimal separator
            // isn't the same as the decimal separator on a keyboard
            let inputFormatter = NumberFormatter()
            if string.contains(".") {
                inputFormatter.decimalSeparator = "."
            } else if string.contains(",") {
                inputFormatter.decimalSeparator = ","
            } else if let separator = Locale.current.decimalSeparator,
                string.contains(separator){
                inputFormatter.decimalSeparator = separator
            } else {
                inputFormatter.decimalSeparator = Localization.language.locale.decimalSeparator
            }
            guard let inputNumber = inputFormatter.number(from: string) else {
                return false
            }

            let itemFormatter = NumberFormatter()
            itemFormatter.decimalSeparator = "."
            for maskPart in mask.split(separator: ";") {
                let items = maskPart
                    .split(separator: "-")
                    .compactMap({ itemFormatter.number(from: String($0)) })

                if items.count == 2,
                    let boundMin = items.first,
                    let boundMax = items.last {
                    // boundaries part
                    if boundMin.compare(inputNumber) != .orderedDescending,
                        boundMax.compare(inputNumber) != .orderedAscending {
                        return true
                    }
                } else if items.contains(inputNumber) {
                    // exact numbers part
                    return true
                }
            }

            return false
        }

        private func isCorrectUserAnswer(forQuestion: Question,
                                         predicate: (Answer) -> Bool) -> Bool {
            if let correctAnswers = forQuestion.answers?.filter({ $0.isTrue == true }) {
                return correctAnswers.contains(where: predicate)
            }
            return false
        }

        private func isAnswerCorrect() -> Bool {
            guard let type = self.question.type else {
                return false
            }

            let userAnswerString = self.answer?.value as? String
            switch type {
            case .oneCorrect,
                 .oneCorrectImage,
                 .trueFalse:
                return isCorrectUserAnswer(forQuestion: self.question,
                                           predicate: { (correctAnswer) -> Bool in
                                            correctAnswer.identifier == userAnswerString
                })
            case .number:
                return compareNumberString(string: userAnswerString,
                                           to: self.question.answerString)
            case .exactMatch:
                return compareAnswerStrings(str1: self.question.answerString,
                                            str2: userAnswerString)
            case .someCorrect,
                 .someCorrectImages:
                let correctAnswers = self.question.answers?.filter({ $0.isTrue == true }) ?? []
                let correctIdSet = Set(correctAnswers.compactMap({ $0.identifier }))
                let userAnswerIdSet = Set(self.answer?.valueArray ?? [])
                return correctIdSet == userAnswerIdSet
            case .sequence:
                let correctSequence = self.question.answers?.compactMap({ $0.value }) ?? []
                var isCorrect = correctSequence.isEmpty
                if let userSequence = self.answer?.valueArray {
                    if correctSequence.count == userSequence.count {
                        isCorrect = zip(correctSequence, userSequence)
                            .filter({ $0 != $1 }).isEmpty
                    } else {
                        isCorrect = false
                    }
                }
                return isCorrect
            case .conformity:
                guard let correctConformity = self.question.answers?
                    .reduce([String : String](),
                            { (dict, answer) -> [String : String] in
                                var dict = dict
                                if let key = answer.key,
                                    let value = answer.value {
                                    dict[key] = value
                                }
                                return dict
                    }) else {
                        return self.answer?.valueDictionary.isEmpty ?? true
                }

                if let userConformity = self.answer?.valueDictionary {
                    return correctConformity == userConformity
                }
                return false
            case .conformityImage:
                guard let correctConformity = self.question.answers?
                    .reduce([String : String](),
                            { (dict, answer) -> [String : String] in
                                var dict = dict
                                if let key = answer.identifier,
                                    let value = answer.value {
                                    dict[key] = value
                                }
                                return dict
                    }) else {
                        return self.answer?.valueDictionary.isEmpty ?? true
                }

                if let userConformity = self.answer?.valueDictionary {
                    return correctConformity == userConformity
                }
                return false
            }
        }
    }
}

extension Questionnaire {

    var questionsTotal: Int {
        return self.questionItems.count
    }

    var questionsCorrect: Int {
        return self.questionItems.filter({ (item) -> Bool in
            return item.answer?.isCorrect ?? false
        }).count
    }

    func isTestPassed() -> Bool {
        let questionsTotal = self.questionsTotal
        let questionsCorrect = self.questionsCorrect
        let allowedErrors = self.course.allowableErrorsCount ?? 0

        return (questionsTotal - questionsCorrect) <= allowedErrors
    }
}

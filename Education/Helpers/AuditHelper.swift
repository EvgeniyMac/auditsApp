//
//  AuditHelper.swift
//  Education
//
//  Created by Andrey Medvedev on 02.03.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import Foundation

class AuditHelper {
    static func questionsList(from audit: Audit?) -> [AuditQuestion]? {
        return audit?.groupedQuestions?
            .compactMap({
                $0.questions?.sorted(by: { (first, second) -> Bool in
                    if let firstSort = first.sort {
                        if let secondSort = second.sort {
                            return firstSort < secondSort
                        } else {
                            return false
                        }
                    } else {
                        return true
                    }
                })
            })
            .flatMap({ $0 })
    }

    static func isValidToBeSent(audit: Audit?,
                                with answers: [AuditAnswer]) -> AuditError? {
        guard let audit = audit else {
            return .noAudit
        }

        let questions = AuditHelper.questionsList(from: audit) ?? []
        for question in questions {
            guard let answer = answers.first(where: {
                $0.questionId == question.identifier
            }) else {
                return .noAnswer(question: question)
            }

            if question.commentRequired,
                (answer.comment?.isEmpty ?? true) {
                return .emptyComment(question: question)
            }

            if let photoMin = question.photoPreferences?.count,
                answer.media.photos.count < photoMin {
                return .emptyPhoto(question: question)
            }
        }
        return nil
    }
}

enum AuditError: Error {
    case noAudit
    case noAnswer(question: AuditQuestion)
    case emptyComment(question: AuditQuestion)
    case emptyAnswer(question: AuditQuestion)
    case emptyPhoto(question: AuditQuestion)
    case emptyVideo(question: AuditQuestion)
}

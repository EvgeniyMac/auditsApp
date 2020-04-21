//
//  AuditQuestionData.swift
//  Education
//
//  Created by Andrey Medvedev on 22.03.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import Foundation

class AuditQuestionData {
    /*private*/ var commentsData: CommentsBundle
    var comments: CommentsBundle {
        return self.commentsData
    }

    /*private*/ var questionData: AuditQuestion
    var question: AuditQuestion {
        return self.questionData
    }

    /*private*/ var answerData: AuditAnswer
    var answer: AuditAnswer {
        return self.answerData
    }

    /*private*/ var previewImageIndex: Int?
    var selectedPreviewImageIndex: Int? {
        return self.previewImageIndex
    }

    init(commentsData: CommentsBundle,
         questionData: AuditQuestion,
         answerData: AuditAnswer,
         previewImageIndex: Int?) {
        self.commentsData = commentsData
        self.questionData = questionData
        self.answerData = answerData
        self.previewImageIndex = previewImageIndex
    }
}

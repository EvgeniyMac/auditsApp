//
//  QuestionnaireManager.swift
//  Education
//
//  Created by Andrey Medvedev on 30/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

class QuestionnaireManager {
    static let shared = QuestionnaireManager()

    private var latestQuestionnaire: Questionnaire?
    public var latest: Questionnaire? {
        return self.latestQuestionnaire
    }

    public func setQuestionnaire(_ q: Questionnaire?) {
        self.latestQuestionnaire = q
    }
}

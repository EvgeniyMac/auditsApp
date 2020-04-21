//
//  Questionnaire+UserAnswer.swift
//  Education
//
//  Created by Andrey Medvedev on 13/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

extension Questionnaire {

    class UserAnswer {
        var value: Any?
        var valueArray = [String]()
        var valueDictionary = [String: String]()
        var responseTime: Int?
        var isCorrect: Bool = false

        func isValid() -> Bool {
            return (value != nil)
                || !valueArray.isEmpty
                || !valueDictionary.isEmpty
        }
    }
}

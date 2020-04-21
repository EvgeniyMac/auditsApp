//
//  Questionnaire.swift
//  Education
//
//  Created by Andrey Medvedev on 13/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation
import ObjectMapper

class Questionnaire {

    let course: Course
    let material: Material
    var questionItems: [Item]

    init(with material: Material, from course: Course) {
        self.course = course
        self.material = material

        self.questionItems = [Item]()
        material.questions?.forEach({ (question) in
            let item = Item(with: question)
            questionItems.append(item)
        })
    }

    func getTotalAnswerTime() -> TimeInterval {
        let timeInt = questionItems
            .map({ $0.answer?.responseTime ?? 0 })
            .reduce(0, +)
        return TimeInterval(timeInt)
    }
}

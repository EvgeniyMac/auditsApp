//
//  QuestionType.swift
//  Education
//
//  Created by Andrey Medvedev on 30/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

enum QuestionType: String {
    case number
    case oneCorrect = "one_correct" // select one correct answers
    case someCorrect = "some_correct" // select all correct answers
    case sequence // put "values" in sequence
    case conformity // put "values" to "keys"
    case conformityImage = "conformity_image" // put "values" to images("keys")
    case exactMatch = "exact_match" // compare text input with "true_answer"
    case trueFalse = "true_false" // compare user opinion(is true...?) with "is_true"
    case oneCorrectImage = "one_correct_image"
    case someCorrectImages = "some_correct_images"
}

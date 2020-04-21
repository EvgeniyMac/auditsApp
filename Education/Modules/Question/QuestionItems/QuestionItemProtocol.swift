//
//  QuestionItemProtocol.swift
//  Education
//
//  Created by Andrey Medvedev on 15/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

enum QuestionItem {
    case sequence
    case conformity
}

protocol QuestionItemProtocol {

}

protocol QuestionItemViewProtocol {
    var onCompletion: ((Questionnaire.UserAnswer?) -> Void)? { get set }

    func setupWith(item: Questionnaire.Item, readonly: Bool)
    func updateState(readonly: Bool)
}

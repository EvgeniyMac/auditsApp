//
//  BaseQuestionItemViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 15/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class BaseQuestionItemViewController: UIViewController, QuestionItemViewProtocol {

    var onCompletion: ((Questionnaire.UserAnswer?) -> Void)?

    private var itemValue: Questionnaire.Item?
    public var item: Questionnaire.Item? {
        return self.itemValue
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        reload()
    }

    // MARK: - Open methods
    open func handleItem(_ item: Questionnaire.Item) {
        self.itemValue = item
    }

    open func reload() {

    }

    // MARK: - QuestionItemViewProtocol
    func setupWith(item: Questionnaire.Item, readonly: Bool) {
        handleItem(item)
        self.view.isUserInteractionEnabled = !readonly

        if self.isViewLoaded {
            reload()
        }
    }

    func updateState(readonly: Bool) {
        self.view.isUserInteractionEnabled = !readonly
    }

    // MARK: - Private
}

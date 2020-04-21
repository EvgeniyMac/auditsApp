//
//  AnswerOptionTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 29/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

enum OptionSelectionType {
    case single
    case multiple
}

class AnswerOptionTableViewCell: UITableViewCell {

    @IBOutlet private weak var stackView: UIStackView!

    public var onChangeState: (([String]) -> Void)? {
        didSet {
            self.onChangeState?(self.state)
        }
    }

    private var kStackViewSpacing: CGFloat = 12

    private var selectionType = OptionSelectionType.single
    private var options = [Answer]()
    private var state = [String]()
    private var isEditable = true

    override func awakeFromNib() {
        super.awakeFromNib()

        self.stackView.spacing = kStackViewSpacing
    }

    func update(withOptions options: [Answer],
                type: OptionSelectionType,
                isEditable: Bool,
                predefinedState: [String]? = nil) {
        self.selectionType = type
        self.isEditable = isEditable
        self.options = options
        if let predefinedState = predefinedState {
            self.state = predefinedState
        } else {
            self.state.removeAll()
        }

        clearInteractiveSubviews()
        setupOptionsStack(with: options)
        updateUI()
    }

    // MARK: - Private
    private func clearInteractiveSubviews() {
        self.stackView.removeAllArrangedSubviews()
    }

    private func getDeselectedImage() -> UIImage? {
        return nil
    }

    private func setupOptionsStack(with options: [Answer]) {
        for option in options {
            if let optionView = AnswerOptionView.instanceFromNib() {
                optionView.statusImage.image = getDeselectedImage()
                optionView.optionLabel.text = option.answer
                optionView.selection = self.selectionType
                optionView.onSelectOption = { [weak self] (optionSelected) in
                    if let optionId = option.identifier {
                        self?.applyValue(optionId)
                    }
                    self?.updateUI()
                }
                self.stackView.addArrangedSubview(optionView)
            }
        }

        // adding placeholder view
        let placeholder = UIView()
        placeholder.setContentHuggingPriority(.required, for: .vertical)
        placeholder.setContentCompressionResistancePriority(UILayoutPriority(0), for: .vertical)
        self.stackView.addArrangedSubview(placeholder)
    }

    private func applyValue(_ value: String) {
        if let index = self.state.firstIndex(of: value) {
            // deselecting an already selected item
            self.state.remove(at: index)
        } else {
            // selecting an item that wasn't selected
            if self.selectionType == .single {
                self.state.removeAll()
            }
            self.state.append(value)
        }

        self.onChangeState?(self.state)
    }

    private func updateUI() {
        for item in self.stackView.arrangedSubviews.enumerated() {
            guard let optionView = item.element as? AnswerOptionView,
                let optionId = self.options[item.offset].identifier else {
                continue
            }

            optionView.optionButton.isEnabled = self.isEditable
            let isOptionSelected = self.state.contains(optionId)

            // setting up an OptionView state
            if isOptionSelected {
                optionView.state = .selected
            } else if self.state.isEmpty {
                optionView.state = .initial
            } else {
                switch self.selectionType {
                case .single:
                    optionView.state = .unselected(isActive: false)
                case .multiple:
                    // for multiple selection: unselected options after answering
                    // should be marked gray
                    optionView.state = .unselected(isActive: self.isEditable)
                }
            }

            let imageSelected = UIImage(named: "answer_option_icon")
            optionView.statusImage.image = isOptionSelected ? imageSelected : nil
            optionView.optionLabel.backgroundColor = .clear
        }
    }
}

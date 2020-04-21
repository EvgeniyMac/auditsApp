//
//  AnswerSequenceTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 29/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class AnswerSequenceTableViewCell: UITableViewCell {

    @IBOutlet weak var answerContainer: UIView!
    @IBOutlet weak var answerStackView: UIStackView!
    @IBOutlet weak var commentContainer: UIView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var optionsContainer: UIView!
    @IBOutlet weak var optionsStackView: UIStackView!
    @IBOutlet weak var resultContainer: UIView!
    @IBOutlet weak var resultImageView: UIImageView!

    public var onChangeState: ((ConformityMatchState) -> Void)? {
        didSet {
            self.onChangeState?(self.state)
        }
    }
    public var matchingSeparator = " "

    private var keys = [String]()
    private var values = [String]()
    private var state = ConformityMatchState()

    private let resultLineHeight = CGFloat(22)
    private let attachmentImageHeight = CGFloat(38)

    override func awakeFromNib() {
        self.commentLabel.font = AppStyle.Font.light(15)
        self.commentLabel.textColor = AppStyle.Color.textMain
    }

    func update(withKeys keys: [String],
                values: [String],
                isEditable: Bool,
                predefinedState: ConformityMatchState) {
        self.keys = keys
        self.values = values
        self.isUserInteractionEnabled = isEditable
        self.state = predefinedState

        clearInteractiveSubviews()
        setupAnswersStack(with: keys)
        if isEditable {
            setupOptionsStack(with: values)
        }

        updateUI()
    }

    private func clearInteractiveSubviews() {
        self.answerStackView.removeAllArrangedSubviews()
        self.optionsStackView.removeAllArrangedSubviews()
    }

    private func setupAnswersStack(with keys: [String]) {
        for key in keys {
            if let resultView = ConformityResultView.instanceFromNib() {
                resultView.resultLabel.text = key
                resultView.onCancelResult = { [weak self] in
                    self?.removeKey(key)
                    self?.updateUI()
                }
                self.answerStackView.addArrangedSubview(resultView)
            }
        }
    }

    private func setupOptionsStack(with values: [String]) {
        for value in values {
            if let optionView = ConformityOptionView.instanceFromNib() {
                optionView.optionLabel.text = value
                optionView.onSelectOption = { [weak self] in
                    self?.applyValue(value)
                    self?.updateUI()
                }
                self.optionsStackView.addArrangedSubview(optionView)
            }
        }

        // adding placeholder view
        let placeholder = UIView()
        placeholder.setContentHuggingPriority(.required, for: .vertical)
        placeholder.setContentCompressionResistancePriority(UILayoutPriority(0), for: .vertical)
        self.optionsStackView.addArrangedSubview(placeholder)
    }

    private func applyValue(_ value: String) {
        if let item = self.state.firstItemWithoutValue() {
            item.value = value
        }
        self.onChangeState?(self.state)
    }

    private func removeKey(_ key: String) {
        if let item = self.state.itemWithKey(key) {
            item.value = nil
        }
        self.onChangeState?(self.state)
    }

    private func updateUI() {
        var shouldShowPlaceholder = true
        for item in self.answerStackView.arrangedSubviews.enumerated() {
            guard let resultView = item.element as? ConformityResultView,
                item.offset < self.keys.count else {
                continue
            }

            let key = self.keys[item.offset]

            if let stateObject = self.state.itemWithKey(key),
                (stateObject.value != nil) || (stateObject.isCorrect != nil) {
                let text = attributedString(forKey: key,
                                            separator: self.matchingSeparator,
                                            value: stateObject.value)
                resultView.resultLabel.attributedText = text
                resultView.cancelButton.isEnabled = true
                resultView.cancelButton.isHidden = false

                if let isCorrect = stateObject.isCorrect {
                    let image = isCorrect ? AppStyle.Image.answerCorrect : AppStyle.Image.answerIncorrect
                    resultView.cancelButton.setImage(image, for: .normal)
                } else {
                    let image = UIImage(named: "answer_cancel_icon")?
                        .withRenderingMode(.alwaysTemplate)
                    resultView.cancelButton.setImage(image, for: .normal)
                }
            } else {
                let text = attributedString(forKey: key,
                                            separator: nil,
                                            value: nil,
                                            showPlaceholder: shouldShowPlaceholder)
                shouldShowPlaceholder = false
                resultView.resultLabel.attributedText = text
                resultView.cancelButton.isEnabled = false
                resultView.cancelButton.isHidden = true
            }
        }

        for item in self.optionsStackView.arrangedSubviews.enumerated() {
            guard let resultView = item.element as? ConformityOptionView,
                item.offset < self.values.count else {
                continue
            }

            let value = self.values[item.offset]
            resultView.isHidden = self.state.hasItemWithValue(value)
        }
    }

    private func attributedString(forKey key: String,
                                  separator: String?,
                                  value: String?,
                                  showPlaceholder: Bool = false) -> NSAttributedString? {
        let result = NSMutableAttributedString()
        result.append(key.attributed(textColor: AppStyle.Color.textMain))
        if let separator = separator {
            result.append(separator.attributed(textColor: AppStyle.Color.textMain))
        }
        if let value = value {
            result.append(value.attributed(textColor: AppStyle.Color.textSupplementary))
        }

        if showPlaceholder {
            result.append(NSAttributedString(string: "  "))
            result.append(createImageAttachmentString())
        }

        return result
    }

    private func createImageAttachmentString() -> NSAttributedString {
        let attachment = NSTextAttachment()
        let image = UIImage(named: "sequence_placeholder")!
        attachment.image = image

        // setting size of image attachment:
        let imageRatio = self.attachmentImageHeight / image.size.height
        let imageSize = CGSize(width: image.size.width * imageRatio,
                               height: self.attachmentImageHeight)
        let verticalOffset = (self.resultLineHeight - self.attachmentImageHeight) / 2
        attachment.bounds = CGRect(origin: CGPoint(x: 0, y: verticalOffset),
                                   size: imageSize)

        return NSAttributedString(attachment: attachment)
    }
}

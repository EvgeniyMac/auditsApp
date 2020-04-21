//
//  AuditInputTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 20.02.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import UIKit
import GrowingTextView

class AuditInputTableViewCell: UITableViewCell {

    var onChange: ((String) -> Void)?
    var onPressSend: ((String?) -> Void)?

    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var attachmentButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.textView.backgroundColor = UIColor.clear
        self.textView.text = nil
        self.textView.placeholder = Localization.string("audit.details.input.placeholder")
        self.textView.placeholderColor = AppStyle.Color.darkGray.withAlphaComponent(0.87)
        self.textView.minHeight = 25
        self.textView.maxHeight = 60

        self.textView.delegate = self
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(handleTextChange),
//                                               name: UITextView.textDidChangeNotification,
//                                               object: self)
    }

    deinit {
//        NotificationCenter.default.removeObserver(self,
//                                                  name: UITextView.textDidChangeNotification,
//                                                  object: self)
    }

    // MARK: - Actions
    @objc private func handleTextChange() {
        self.onChange?(self.textView.text)
    }

    @IBAction private func didPressSendButton(_ sender: Any) {
        self.endEditing(true)
        DispatchQueue.main.async { [weak self] in
            self?.onPressSend?(self?.textView.text)
        }
    }
}

extension AuditInputTableViewCell: AuditQuestionTableViewCellProtocol {
    func setup(with auditQuestion: AuditQuestion) {
    }
}

extension AuditInputTableViewCell: AuditAnswerTableViewCellProtocol {
    func setup(answer auditAnswer: AuditAnswer?) {
        self.textView.text = auditAnswer?.comment
    }
}

extension AuditInputTableViewCell: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
    }

    func textViewDidChange(_ textView: UITextView) {
        self.onChange?(textView.text)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        self.onChange?(textView.text)
    }
}

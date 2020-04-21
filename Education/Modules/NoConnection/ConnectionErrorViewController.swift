//
//  ConnectionErrorViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 27/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class ConnectionErrorViewController: UIViewController {

    public var onPressAction: (() -> Void)?
    public var error: NetworkError?

    @IBOutlet weak var errorImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var actionButton: BorderedButton!

    private var shouldHideNavigationBar: Bool {
        guard let error = self.error else {
            // not hiding navigation bar for "under construction" screen (#13264)
            return false
        }

        switch error {
        case .userBlocked:
            return false
        default:
            return true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        setupContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.shouldHideNavigationBar {
            self.parent?.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.shouldHideNavigationBar {
            self.parent?.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }

    // MARK: - Actions
    @IBAction private func didPressActionButton(_ sender: Any) {
        self.onPressAction?()
    }

    // MARK: - Private
    private func configureUI() {
        self.titleLabel.textColor = AppStyle.Color.textMain
        self.titleLabel.font = AppStyle.Font.semibold(24)
        self.titleLabel.textAlignment = .center
        self.titleLabel.numberOfLines = 0

        self.messageLabel.textColor = AppStyle.Color.textSupplementary
        self.messageLabel.font = AppStyle.Font.regular(16)
        self.messageLabel.textAlignment = .center
        self.messageLabel.numberOfLines = 0

        let buttonColor = AppStyle.Color.main
        self.actionButton.layer.borderColor = buttonColor.cgColor
        self.actionButton.layer.borderWidth = AppStyle.Border.default
        self.actionButton.layer.cornerRadius = AppStyle.CornerRadius.button
        self.actionButton.layer.masksToBounds = true
        self.actionButton.setTitleColor(buttonColor, for: .normal)
    }

    private func setupContent() {
        if let error = self.error {
            setupContent(forError: error)
        } else {
            setupContentUnderConstruction()
        }
    }

    private func setupContent(forError: NetworkError) {
        var mainTitle, messageTitle, buttonTitle: String?
        var errorImage: UIImage?
        switch forError {
        case .noInternetConnection:
            mainTitle = Localization.string("error.no_connection.title")
            messageTitle = Localization.string("error.no_connection.message")
            buttonTitle = Localization.string("error.no_connection.action")
            errorImage = UIImage(named: "globe_icon")
        case .userBlocked:
            mainTitle = Localization.string("error.user_blocked.title")
            messageTitle = Localization.string("error.user_blocked.message")
            buttonTitle = Localization.string("error.user_blocked.action")
            errorImage = UIImage(named: "block_icon")
        case .serverError(_):
            mainTitle = Localization.string("error.server_error.title")
            messageTitle = Localization.string("error.server_error.message")
            buttonTitle = Localization.string("error.server_error.action")
            errorImage = UIImage(named: "server_icon")
        default:
            break
        }

        self.errorImageView.image = errorImage
        self.titleLabel.text = mainTitle
        self.messageLabel.text = messageTitle
        self.actionButton.setTitle(buttonTitle, for: .normal)
        self.actionButton.isHidden = false
    }

    private func setupContentUnderConstruction() {
        self.errorImageView.image = UIImage(named: "cat_icon")
        self.titleLabel.text = Localization.string("error.no_content.title")
        self.messageLabel.text = Localization.string("error.no_content.message")
        self.actionButton.setTitle(nil, for: .normal)
        self.actionButton.isHidden = true
    }
}

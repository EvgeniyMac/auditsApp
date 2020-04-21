//
//  CodeConfirmViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 17/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit
import FirebaseAuth
import ActiveLabel

class CodeConfirmViewController: BaseViewController, KeyboardObserver {
    private enum CodeConfirmRow: Int, CaseIterable {
        case info = 0
        case code
        case confirm
        case resend
    }

    var verificationId: String?
    var verificationCode: String?
    var phoneNumber: String?
    var authInfoCellHeight = UITableView.automaticDimension

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var flagButtonRus: UIButton!
    @IBOutlet weak var flagButtonUsa: UIButton!
    @IBOutlet var languagesContainerView: UIView!

    private let kVerificationCodeLength = Int(6)
    private let kVerificationTimeout = TimeInterval(60)
    private var shouldClearInput = true
    private var confirmButton: UIButton?
    private var resendCodeHandler: TimeoutHandler?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTable()
        setupResendTimeoutHandler()
        localizeUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications { [weak self] (offset) in
            self?.tableView.contentInset.bottom = offset
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    // MARK: - Actions
    @objc private func didPressConfirmButton() {
        guard let code = self.verificationCode,
            code.count == kVerificationCodeLength else {
                return
        }

        self.view.endEditing(true)
        authenticate(code)
    }

    @IBAction func didPressFlag(_ sender: Any) {
        guard let button = sender as? UIButton else { return }

        if button == self.flagButtonRus {
            Localization.language = .ru
        } else if button == self.flagButtonUsa {
            Localization.language = .en
        }
    }

    // MARK: - Overridings
    override func localizeUI() {
        super.localizeUI()

        let resendRowIndexPath = IndexPath(row: CodeConfirmRow.resend.rawValue, section: 0)
        self.tableView.reloadRows(at: [resendRowIndexPath], with: .none)

        setupFlagImageView(self.flagButtonRus.imageView,
                           isSelected: Localization.language == .ru)
        setupFlagImageView(self.flagButtonUsa.imageView,
                           isSelected: Localization.language == .en)
    }

    // MARK: - Private
    private func configureTable() {
        [AuthInfoTableViewCell.self,
         CodeInputTableViewCell.self,
         ButtonTableViewCell.self,
         ActiveTextTableViewCell.self]
            .forEach { [unowned self] (type) in
                type.registerNib(at: self.tableView)
        }
    }

    private func setupFlagImageView(_ imgView: UIImageView?, isSelected: Bool) {
        guard let imgView = imgView,
            let imgSize = imgView.image?.size else {
                return
        }

        let cornerRadius = min(imgSize.width, imgSize.height) / 2
        imgView.layer.cornerRadius = cornerRadius
        imgView.layer.borderColor = AppStyle.Color.buttonMain.cgColor
        imgView.layer.borderWidth = isSelected ? 1.0 : 0.0
    }

    private func requestCodeForCurrentPhoneNumber() {
        guard let phoneNumber = phoneNumber else { return }

        setupResendTimeoutHandler()
        requestCode(for: phoneNumber)
    }

    private func setupResendTimeoutHandler() {
        let timeout = Timeout(start: Date(), duration: kVerificationTimeout)
        self.resendCodeHandler = TimeoutHandler(
            timeout: timeout,
            onUpdate: { (remaining) in
                let indexPath = IndexPath(item: CodeConfirmRow.resend.rawValue,
                                          section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .none)
        })
    }

    private func authenticate(_ code: String?) {
        guard let code = code,
            code.count == kVerificationCodeLength else {
                return
        }
        guard let verificationId = self.verificationId else {
            showErrorMessage(withText: Localization.string("code_confirm.verification_id_unavailable"))
            return
        }

        performFirebaseAuth(verificationId: verificationId,
                            verificationCode: code)
    }

    private func performFirebaseAuth(verificationId: String, verificationCode: String) {
        let credential = PhoneAuthProvider.provider()
            .credential(withVerificationID: verificationId,
                        verificationCode: verificationCode)

        showProgressIndicator()
        Auth.auth().signIn(with: credential, completion: { [weak self] (authData, error) in
            self?.hideProgressIndicator()
            if error != nil {
                self?.showAuthErrorMessage(forError: NetworkError.authFailed)
                self?.clearCodeInput()
            } else {
                self?.loginUsingFirebaseUser(authData?.user)
            }
        })
    }

    private func loginUsingFirebaseUser(_ user: FirebaseAuth.User?) {
        guard let user = user else {
            showErrorMessage(forError: .noData)
            return
        }

        showProgressIndicator()
        user.getIDToken(completion: { [weak self] (token, error) in
            self?.hideProgressIndicator()
            if error != nil {
                self?.showAuthErrorMessage(forError: NetworkError.authFailed)
            } else {
                self?.loginUsingFirebaseToken(token)
            }
        })
    }

    private func loginUsingFirebaseToken(_ token: String?) {
        guard let token = token else {
            showErrorMessage(forError: .noData)
            clearCodeInput()
            return
        }

        showProgressIndicator()
        AuthService.authUsingFirebaseToken(
            token: token,
            success: { (authData) in
                self.hideProgressIndicator()
                UserManager.auth = authData

                NotificationManager.requestRemoteNotificationsAuthorization()
                NotificationManager.subscribeToPushNotifications()
                NotificationCenter.default.post(name: .DidAuthorize, object: nil)
        },
            failure: { (error) in
                let onRetry: (() -> Void) = { [weak self] in
                    self?.loginUsingFirebaseToken(token)
                }
                self.hideProgressIndicator()
                self.showAuthErrorMessage(forError: error)
                self.clearCodeInput()
        })
    }

    private func showAuthErrorMessage(forError: NetworkError) {
        switch forError {
        case .deprecatedVersion:
            showErrorMessage(forError: forError)
        default:
            showErrorMessage(forError: NetworkError.authFailed)
        }
    }

    private func requestCode(for phoneNumber: String) {
        let phone = "+" + phoneNumber
        Auth.auth().settings?.isAppVerificationDisabledForTesting = false
        Auth.auth().languageCode = Localization.language.valueShort.lowercased()

        showProgressIndicator()
        PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) {
            [weak self] (verificationID, error) in
            self?.hideProgressIndicator()

            if let error = error {
                self?.showErrorMessage(withText: error.localizedDescription)
            } else {
                self?.verificationId = verificationID
            }
        }
    }

    private func clearCodeInput() {
        self.shouldClearInput = true
        self.tableView.reloadData()
    }

    private func refreshConfirmButtonStatus() {
        if let code = self.verificationCode,
            code.count == kVerificationCodeLength {
            self.confirmButton?.isEnabled = true
            self.confirmButton?.backgroundColor = AppStyle.Color.buttonMain
        } else {
            self.confirmButton?.isEnabled = false
            self.confirmButton?.backgroundColor = AppStyle.Color.buttonDisabled
        }
    }
}

extension CodeConfirmViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension CodeConfirmViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let row = CodeConfirmRow(rawValue: indexPath.row) else {
            fatalError("CodeRequest table has an excessive cell")
        }

        switch row {
        case .info:
            return self.authInfoCellHeight
        default:
            return UITableView.automaticDimension
        }
    }
}

extension CodeConfirmViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return CodeConfirmRow.allCases.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = CodeConfirmRow(rawValue: indexPath.row) else {
            fatalError("CodeRequest table has an excessive cell")
        }

        switch row {
        case .info:
            return createInfoTableViewCell(table: tableView, indexPath: indexPath)
        case .code:
            return createCodeTableViewCell(tableView: tableView, indexPath: indexPath)
        case .confirm:
            return createButtonTableViewCell(table: tableView, indexPath: indexPath)
        case .resend:
            return createResendTableViewCell(table: tableView, indexPath: indexPath)
        }
    }

    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        if let cell = cell as? CodeInputTableViewCell {
            if #available(iOS 12.0, *) {
                cell.textField1.textContentType = .oneTimeCode
            }
            cell.textField1.becomeFirstResponder()
        }
    }

    private func createInfoTableViewCell(table: UITableView,
                                         indexPath: IndexPath) -> AuthInfoTableViewCell {
        let identifier = AuthInfoTableViewCell.reuseIdentifier()
        guard let cell = table.dequeueReusableCell(withIdentifier: identifier) as? AuthInfoTableViewCell else {
            fatalError("Unable to create AuthInfoTableViewCell")
        }

        cell.titleLabel.text = Localization.string("code_confirm.info_title")
        cell.subtitleLabel.text = Localization.string("code_confirm.info_subtitle")
        cell.selectionStyle = .none

        return cell
    }

    private func createCodeTableViewCell(tableView: UITableView,
                                         indexPath: IndexPath) -> CodeInputTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CodeInputTableViewCell.reuseIdentifier(),
            for: indexPath) as? CodeInputTableViewCell else {
                fatalError("Unable to create TextTableViewCell")
        }

        cell.onChangedInput = { [weak self] (code) in
            self?.verificationCode = code
            self?.refreshConfirmButtonStatus()
        }
        if self.shouldClearInput {
            shouldClearInput = false
            cell.resetTextFields()
        }

        cell.selectionStyle = .none
        return cell
    }

    private func createButtonTableViewCell(table: UITableView,
                                           indexPath: IndexPath) -> ButtonTableViewCell {
        let identifier = ButtonTableViewCell.reuseIdentifier()
        guard let cell = table.dequeueReusableCell(withIdentifier: identifier) as? ButtonTableViewCell else {
            fatalError("Unable to create ButtonTableViewCell")
        }

        let titleKey = "code_confirm.confirm_button_title"
        cell.button.setTitle(Localization.string(titleKey), for: .normal)
        cell.button.backgroundColor = AppStyle.Color.buttonMain
        cell.button.addTarget(self,
                              action: #selector(didPressConfirmButton),
                              for: .touchUpInside)

        self.confirmButton = cell.button
        refreshConfirmButtonStatus()
        cell.selectionStyle = .none

        return cell
    }

    private func createResendTableViewCell(table: UITableView,
                                           indexPath: IndexPath) -> ActiveTextTableViewCell {
        let identifier = ActiveTextTableViewCell.reuseIdentifier()
        guard let cell = table.dequeueReusableCell(withIdentifier: identifier) as? ActiveTextTableViewCell else {
            fatalError("Unable to create ActiveTextTableViewCell")
        }

        let textIntro = Localization.string("code_confirm.resend_intro")
        var textAction = Localization.string("code_confirm.resend_action_title")
        var isRefreshAvailable = true
        if let timeout = self.resendCodeHandler?.timeout {
            let refreshTimeout = Int(timeout.remainingTime)
            if refreshTimeout > .zero {
                isRefreshAvailable = false
                textAction += " \(refreshTimeout)"
            }
        }

        let actionType = ActiveType.custom(pattern: "\\s\(textAction)\\b")
        cell.activeLabel.enabledTypes = [actionType]
        cell.activeLabel.handleCustomTap(for: actionType) { [unowned self] (_) in
            guard isRefreshAvailable else { return }
            self.view.endEditing(true)
            self.requestCodeForCurrentPhoneNumber()
        }

        //customize active text:
        let refreshStyle = isRefreshAvailable ?
            AppStyle.Text.subtitleAction : AppStyle.Text.subtitleDisabled
        cell.activeLabel.customize { (activeLabel) in
            let attributedText = NSMutableAttributedString()
            attributedText.append(textIntro.attributed(with: AppStyle.Text.subtitleDefault))
            attributedText.append(textAction.attributed(with: refreshStyle))
            activeLabel.attributedText = attributedText

            activeLabel.configureLinkAttribute = { (_, _, _) in
                return refreshStyle
            }
        }
        cell.activeLabel.textAlignment = .center
        cell.selectionStyle = .none

        return cell
    }
}

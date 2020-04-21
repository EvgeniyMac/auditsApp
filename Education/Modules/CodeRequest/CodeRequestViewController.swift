//
//  CodeRequestViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 17/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit
import CountryPickerView
import InputMask
import FirebaseAuth
import ActiveLabel

class CodeRequestViewController: BaseViewController, KeyboardObserver {
    private enum CodeRequestRow: Int, CaseIterable {
        case info = 0
        case phone
        case proceed
        case terms
    }

    private let kProceedCellHeight = UIDevice().iPhones_4_4S ? CGFloat(64) : CGFloat(74)
    private let kTableFooterHeightMin = CGFloat(64)
    private var phoneInputString = String()
    private var verificationId: String?
    private var authInfoCellHeight = UITableView.automaticDimension

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var flagButtonRus: UIButton!
    @IBOutlet weak var flagButtonUsa: UIButton!
    @IBOutlet var languagesContainerView: UIView!

    private var countryPickerView = CountryPickerView()
    private var phoneTextField: UITextField?
    private var proceedButton: UIButton?
    private var listener: CodeRequestTextFieldDelegate = CodeRequestTextFieldDelegate(
        primaryFormat: "([000]) [000]-[00]-[00]",
        autocomplete: false,
        autocompleteOnFocus: false,
        rightToLeft: false,
        affineFormats: ["([000]) [000]-[00]-[00]"],
        affinityCalculationStrategy: AffinityCalculationStrategy.prefix,
        customNotations: [],
        onMaskedTextChangedCallback: nil)

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCodeConfirmViewController" {
            if let destinationVC = segue.destination as? CodeConfirmViewController {
                destinationVC.phoneNumber = self.getPhoneNumber()
                destinationVC.verificationId = sender as? String
                destinationVC.authInfoCellHeight = self.authInfoCellHeight
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTable()
        configureCountryPickerView()
        configureInputListener()
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

        // FIX: fix to handle appearing anti-robot menu
        hideProgressIndicator()
    }

    // MARK: - Actions
    @objc private func didPressProceedButton() {
        self.view.endEditing(true)

        requestCode(for: self.getPhoneNumber())
    }

    @IBAction private func didPressFlag(_ sender: Any) {
        guard let button = sender as? UIButton else { return }

        if button == self.flagButtonRus {
            Localization.language = .ru
        } else if button == self.flagButtonUsa {
            Localization.language = .en
        }
    }

    @IBAction private func didHandleTap(_ sender: Any) {
        self.view.endEditing(true)
    }

    @objc private func didTriggerSecretAction(_ sender: Any) {
        let alert = UIAlertController(title: Localization.string("common.server_url_change_title"),
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .URL
            textField.text = Networking.serverUrl?.absoluteString
        }
        alert.addAction(UIAlertAction(
            title: Localization.string("common.ok"),
            style: .default,
            handler: { [unowned self, unowned alert] _ in
                let string = alert.textFields?.first?.text
                self.handleServerUrl(string: string)
        }))
        alert.addAction(UIAlertAction(title: Localization.string("common.cancel"),
                                      style: .cancel,
                                      handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func handleServerUrl(string: String?) {
        if let string = string,
            let serverUrl = URL(string: string),
            serverUrl.scheme != nil {
            Networking.serverUrl = serverUrl
        } else {
            let message = Localization.string("error.incorrect_server_url")
            self.showErrorMessage(withText: message)
        }
    }

    // MARK: - Overridings
    override func localizeUI() {
        super.localizeUI()

        self.tableView.reloadData()

        setupFlagImageView(self.flagButtonRus.imageView,
                           isSelected: Localization.language == .ru)
        setupFlagImageView(self.flagButtonUsa.imageView,
                           isSelected: Localization.language == .en)
    }

    // MARK: - Private
    private func configureTable() {
        [AuthInfoTableViewCell.self,
         PhoneTableViewCell.self,
         ButtonTableViewCell.self,
         ActiveTextTableViewCell.self]
            .forEach { [unowned self] (type) in
                type.registerNib(at: self.tableView)
        }
    }

    private func configureInputListener() {
        listener.onMaskedTextChangedCallback = { [weak self] (_, value, completed) in
            self?.phoneInputString = value
            self?.proceedButton?.isEnabled = completed
            let color = completed ? AppStyle.Color.buttonMain : AppStyle.Color.buttonDisabled
            self?.proceedButton?.backgroundColor = color
        }
        listener.onCheckCountryCode = { [weak self] in
            return self?.countryPickerView.selectedCountry.phoneCode
        }
    }

    private func setupSecretGestureRecognizerFor(view: UIView) {
        let selector = #selector(didTriggerSecretAction(_:))
        let recognizer = UITapGestureRecognizer(target: self,
                                                action: selector)
        recognizer.numberOfTapsRequired = 10
        recognizer.delegate = self
        view.addGestureRecognizer(recognizer)
        view.isUserInteractionEnabled = true
    }

    private func configureCountryPickerView() {
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
        countryPickerView.showPhoneCodeInView = true
        countryPickerView.showCountryCodeInView = true

        let countryCode = Utilities.isoCountryCode() ?? Constants.countryCodeDefault
        countryPickerView.setCountryByCode(countryCode.uppercased())
    }

    private func getPhoneNumber() -> String {
        let code = self.countryPickerView.selectedCountry.phoneCode
        let rawNumber = code + (self.phoneTextField?.text ?? String())
        let charset = CharacterSet.decimalDigits.inverted
        return rawNumber.components(separatedBy: charset).joined()
    }

    private func setupFlagImageView(_ imgView: UIImageView?, isSelected: Bool) {
        guard let imgView = imgView,
            let imgSize = imgView.image?.size else {
                return
        }

        let cornerRadius = min(imgSize.width, imgSize.height) / 2
        imgView.layer.cornerRadius = cornerRadius
        imgView.layer.borderColor = AppStyle.Color.buttonMain.cgColor
        let borderWidth = isSelected ? AppStyle.Border.default : AppStyle.Border.none
        imgView.layer.borderWidth = borderWidth
    }

    private func requestCode(for phoneNumber: String) {
        let phone = "+" + phoneNumber
        Auth.auth().settings?.isAppVerificationDisabledForTesting = false
        Auth.auth().languageCode = Localization.language.valueShort.lowercased()

        showProgressIndicator()
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(phone, uiDelegate: nil) { [weak self] (verificationID, error) in
                self?.hideProgressIndicator()

                if let error = error {
                    self?.showErrorMessage(withText: error.localizedDescription)
                } else {
                    self?.openCodeConfirm(verificationId: verificationID)
                }
        }
    }

    private func openCodeConfirm(verificationId: String?) {
        self.performSegue(withIdentifier: "toCodeConfirmViewController",
                          sender: verificationId)
    }
}

extension CodeRequestViewController: CountryPickerViewDelegate, CountryPickerViewDataSource {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        self.tableView.reloadData()
    }
}

extension CodeRequestViewController: UIGestureRecognizerDelegate {
}

extension CodeRequestViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let row = CodeRequestRow(rawValue: indexPath.row) else {
            fatalError("CodeRequest table has an excessive cell")
        }

        switch row {
        case .proceed:
            return kProceedCellHeight
        default:
            return UITableView.automaticDimension
        }
    }
}

extension CodeRequestViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return CodeRequestRow.allCases.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = CodeRequestRow(rawValue: indexPath.row) else {
            fatalError("CodeRequest table has an excessive cell")
        }

        switch row {
        case .info:
            return createInfoTableViewCell(table: tableView,
                                           indexPath: indexPath)
        case .phone:
            return createPhoneTableViewCell(table: tableView,
                                            indexPath: indexPath,
                                            country: self.countryPickerView.selectedCountry)
        case .proceed:
            return createButtonTableViewCell(table: tableView, indexPath: indexPath)
        case .terms:
            return createTermsTableViewCell(table: tableView, indexPath: indexPath)
        }
    }

    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        if let infoCell = cell as? AuthInfoTableViewCell {
            self.authInfoCellHeight = infoCell.frame.height
        }
    }

    private func createPhoneTableViewCell(table: UITableView,
                                          indexPath: IndexPath,
                                          country: Country) -> PhoneTableViewCell {
        let identifier = PhoneTableViewCell.reuseIdentifier()
        guard let cell = table.dequeueReusableCell(withIdentifier: identifier) as? PhoneTableViewCell else {
            fatalError("Unable to create PhoneTableViewCell")
        }

        let titleText = Localization.string("code_request.phone_number")
        cell.titleLabel.text = titleText.uppercased()
        cell.countryCodeLabel.text = country.phoneCode
        cell.flagImageView.image = country.flag
        cell.phoneTextField.returnKeyType = .done
        if #available(iOS 10.0, *) {
            cell.phoneTextField.textContentType = .telephoneNumber
        }
        cell.phoneTextField.delegate = self.listener
        cell.phoneTextField.becomeFirstResponder()
        self.phoneTextField = cell.phoneTextField

        cell.onPressCountryCode = { [weak self] in
            self?.showCountryPicker()
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

        let titleKey = "code_request.proceed_button_title"
        cell.button.setTitle(Localization.string(titleKey), for: .normal)
        cell.button.backgroundColor = AppStyle.Color.buttonMain
        cell.button.addTarget(self,
                              action: #selector(didPressProceedButton),
                              for: .touchUpInside)

        self.proceedButton = cell.button
        refreshProceedButtonStatus()
        cell.selectionStyle = .none

        return cell
    }

    private func refreshProceedButtonStatus() {
        guard let textField = self.phoneTextField else { return }
        self.listener.put(text: self.phoneInputString, into: textField)
    }

    private func showCountryPicker() {
        self.countryPickerView.showCountriesList(from: self)
    }

    private func createInfoTableViewCell(table: UITableView,
                                         indexPath: IndexPath) -> AuthInfoTableViewCell {
        let identifier = AuthInfoTableViewCell.reuseIdentifier()
        guard let cell = table.dequeueReusableCell(withIdentifier: identifier) as? AuthInfoTableViewCell else {
            fatalError("Unable to create AuthInfoTableViewCell")
        }

        cell.titleLabel.text = Localization.string("code_request.info_title")
        cell.subtitleLabel.text = Localization.string("code_request.info_subtitle")
        cell.selectionStyle = .none

        // setting up a secret gesture
        setupSecretGestureRecognizerFor(view: cell.titleLabel)

        return cell
    }

    private func createTermsTableViewCell(table: UITableView,
                                          indexPath: IndexPath) -> ActiveTextTableViewCell {
        let identifier = ActiveTextTableViewCell.reuseIdentifier()
        guard let cell = table.dequeueReusableCell(withIdentifier: identifier) as? ActiveTextTableViewCell else {
            fatalError("Unable to create ActiveTextTableViewCell")
        }

        let textIntro = Localization.string("code_request.terms_text_terms_intro")
        let textTerms = Localization.string("code_request.terms_text_terms")
        let textGdprIntro = Localization.string("code_request.terms_text_gdpr_intro")
        let textGdpr = Localization.string("code_request.terms_text_gdpr")

        let termsType = ActiveType.custom(pattern: "\\s\(textTerms)\\b")
        let gdprType = ActiveType.custom(pattern: "\\s\(textGdpr)\\b")
        cell.activeLabel.enabledTypes = [termsType, gdprType]
        cell.activeLabel.handleCustomTap(for: termsType) { [unowned self] (_) in
            self.view.endEditing(true)
            // TODO: handle pressing label
        }
        cell.activeLabel.handleCustomTap(for: gdprType) { [unowned self] (_) in
            self.view.endEditing(true)
            // TODO: handle pressing label
        }

        //customize active text:
        cell.activeLabel.customize { (activeLabel) in
            let attributedText = NSMutableAttributedString()
            attributedText.append(textIntro.attributed(with: AppStyle.Text.subtitleDefault))
            attributedText.append(textTerms.attributed(with: AppStyle.Text.subtitleAction))
            attributedText.append(textGdprIntro.attributed(with: AppStyle.Text.subtitleDefault))
            attributedText.append(textGdpr.attributed(with: AppStyle.Text.subtitleAction))
            activeLabel.attributedText = attributedText

            activeLabel.configureLinkAttribute = { (_, _, _) in
                return AppStyle.Text.subtitleAction
            }
        }
        cell.activeLabel.textAlignment = .center
        cell.selectionStyle = .none

        return cell
    }
}

extension CodeRequestViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

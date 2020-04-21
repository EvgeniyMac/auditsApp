//
//  AuditQuestionViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 29.02.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import UIKit

class AuditQuestionViewController: BaseViewController, KeyboardObserver {

    private var viewModel = AuditQuestionViewModel(audit: nil)

    @IBOutlet private weak var segmentedHeader: SegmentedHeaderView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var previousButton: CustomButton!
    @IBOutlet private weak var nextButton: CustomButton!

    private lazy var sendButton: BarActionView.Button = {
        let button = BarActionView.createBarActionButton(image: nil)
        button.setImage(UIImage(named: "audit.send.enabled"), for: .normal)
        button.setImage(UIImage(named: "audit.send.disabled"), for: .disabled)
        let sendSelector = #selector(sendAnswer(sender:))
        button.addTarget(self, action: sendSelector, for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureAuditDetailsUI()
        localizeUI()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        subscribeToKeyboardNotifications { [weak self] (offset) in
            self?.updateTableInset(bottomInset: offset)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        unsubscribeFromKeyboardNotifications()
    }

    override func localizeUI() {
        super.localizeUI()

        setupSegmentedHeaderView(header: self.segmentedHeader)
        self.tableView.reloadData()
    }

    override func openUserProfile() {
        self.performSegue(withIdentifier: "toProfile", sender: nil)
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        self.sendButton.isEnabled = false

        let barView = BarActionView()
        barView.setupBarItem(withActions: [.custom(button: self.sendButton),
                                           .settings])
        barView.onPressSettings = { [weak self] in
            self?.showSettings()
        }
        let barItem = UIBarButtonItem(customView: barView)
        self.navigationItem.rightBarButtonItems = [barItem]
    }

    // MARK: - Actions
    @objc private func sendAnswer(sender: Any) {
        sendAnswers(answers: self.viewModel.allAnswers,
                    for: self.viewModel.audit)
    }

    @IBAction func didPressPreviousButton(_ sender: Any) {
        guard let index = self.viewModel.questionIndex else { return }

        configureWith(questionIndex: index - 1)
    }

    @IBAction func didPressNextButton(_ sender: Any) {
        guard let index = self.viewModel.questionIndex else { return }

        configureWith(questionIndex: index + 1)
    }

    // MARK: - Public
    public func configureWith(audit newAudit: Audit, questionIndex: Int) {
        self.viewModel = AuditQuestionViewModel(audit: newAudit)
        self.title = newAudit.name
        configureWith(questionIndex: questionIndex)
    }

    // MARK: - Private
    private func configureAuditDetailsUI() {
        self.tableView.backgroundColor = AppStyle.Color.backgroundSecondary
        self.tableView.estimatedRowHeight = 48

        [TextTableViewCell.self,
         ImageTableViewCell.self,
         AuditTitleTableViewCell.self,
         AuditImageTableViewCell.self,
         AuditImagePreviewTableViewCell.self,
         AuditOptionsTableViewCell.self,
         AuditTilesTableViewCell.self,
         AuditCommentTableViewCell.self,
         AuditInputTableViewCell.self,
         AuditSpaceTableViewCell.self,
         LoadingTableViewCell.self].forEach { [unowned self] (type) in
            type.registerNib(at: self.tableView)
        }

        [self.previousButton, self.nextButton].forEach { (button) in
            button?.titleLabel?.font = AppStyle.Font.regular(14)
            button?.tintColor = AppStyle.Color.buttonSupplementary
            button?.setTitleColor(AppStyle.Color.buttonSupplementary, for: .normal)
            button?.setTitleColor(AppStyle.Color.custom(hex: 0xC1C1C1), for: .disabled)
        }
        self.previousButton.setTitle(Localization.string("common.move.back"),
                                     for: .normal)
        self.nextButton.setTitle(Localization.string("common.move.next"),
                                 for: .normal)
        configureButton(self.previousButton, asEnabled: self.viewModel.hasPreviousQuestion)
        configureButton(self.nextButton, asEnabled: self.viewModel.hasNextQuestion)

        func setupLeftButton(_ button: UIButton) {
            button.setImage(UIImage(named: "arrow.left.small"), for: .normal)
            button.semanticContentAttribute = .forceLeftToRight
            button.imageEdgeInsets = UIEdgeInsets(top: 1, left: -4, bottom: -1, right: 4)
        }
        func setupRightButton(_ button: UIButton) {
            button.setImage(UIImage(named: "arrow.right.small"), for: .normal)
            button.semanticContentAttribute = .forceRightToLeft
            button.imageEdgeInsets = UIEdgeInsets(top: 1, left: 4, bottom: -1, right: -4)
        }

        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            setupLeftButton(self.nextButton)
            setupRightButton(self.previousButton)
        } else {
            setupLeftButton(self.previousButton)
            setupRightButton(self.nextButton)
        }
    }

    private func setupSegmentedHeaderView(header: SegmentedHeaderView) {
        header.backgroundColor = AppStyle.Color.backgroundMain
        header.setupSegments(
            withTitles: self.viewModel.availableTabs.compactMap({ $0.title }),
            selectedIndex: self.viewModel.selectedTab.rawValue,
            handler: { [weak self] (index) in
                guard let vm = self?.viewModel else { return }
                vm.selectedTab = vm.availableTabs[index]
                self?.tableView.reloadData()
            })
        header.resetInsets(.zero)
    }

    private func showSettings() {
        print("show settings")
    }

    private func configureWith(questionIndex: Int) {
        self.viewModel.setupQuestionIndex(questionIndex)

        self.loadComments(forQuestion: self.viewModel.currentQuestion,
                          in: self.viewModel.audit)

        if self.isViewLoaded {
            self.tableView.reloadData()
            configureButton(self.previousButton, asEnabled: self.viewModel.hasPreviousQuestion)
            configureButton(self.nextButton, asEnabled: self.viewModel.hasNextQuestion)
        }
    }

    private func configureButton(_ button: UIButton, asEnabled: Bool) {
        button.isEnabled = asEnabled
        let color = asEnabled ? AppStyle.Color.buttonMain : AppStyle.Color.buttonDisabled
        button.backgroundColor = color
    }
}

extension AuditQuestionViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.sectionsList.count
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.viewModel.sectionsList[indexPath.row]
        let cell = getQuestionTableViewCell(in: tableView, at: indexPath, row: row)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Private
    private func refreshUI() {
        self.sendButton.isEnabled = self.viewModel.isReadyToSend
    }

    private func getQuestionTableViewCell(in tableView: UITableView,
                                          at indexPath: IndexPath,
                                          row: AuditUI.Row) -> UITableViewCell {
        switch row {
        case .groupTitle(let text):
            let cell = tableView.dequeCell(at: indexPath) as TextTableViewCell
            cell.insets = UIEdgeInsets(all: 20)
            cell.contentLabel?.text = text
            cell.contentLabel.font = AppStyle.Font.medium(22)
            cell.contentLabel.textColor = AppStyle.Color.textSelected.withAlphaComponent(0.87)
            return cell
        case .title(let question):
            let cell = tableView.dequeCell(at: indexPath) as AuditTitleTableViewCell
            cell.setup(with: question)
            return cell
        case .image(let question):
            let cell = tableView.dequeCell(at: indexPath) as ImageTableViewCell
            let placeholder = UIImage(named: "audit.image.placeholder")
            cell.loadImageFromUrl(question.imageUrl,
                                  placeholderImage: placeholder,
                                  minRatio: 0.3,
                                  completion: { _ in
                                    UIView.setAnimationsEnabled(false)
                                    tableView.beginUpdates()
                                    tableView.endUpdates()
                                    UIView.setAnimationsEnabled(true)
            })
            return cell
        case .imagesPreview(let question, let index, let urls):
            let cell = tableView.dequeCell(at: indexPath) as AuditImagePreviewTableViewCell
            let selectedImageIndex = self.viewModel.currentSelectedPreviewImageIndex
            cell.setup(with: urls, selectedIndex: selectedImageIndex, auditQuestion: question)

            cell.onPressAddPhotoButton = {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = true
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true, completion: nil)
            }
            cell.onSelectPhotoForPreview = { [weak self] (index) in
                self?.viewModel.setSelectedPreviewImageIndex(indexValue: index)
                UIView.setAnimationsEnabled(false)
                tableView.beginUpdates()
                tableView.endUpdates()
                UIView.setAnimationsEnabled(true)
            }
            return cell
        case .options(let question, let index):
            let cell = tableView.dequeCell(at: indexPath) as AuditOptionsTableViewCell
            cell.setup(with: question)
            cell.onNeedUpdateHeight = {
                UIView.setAnimationsEnabled(false)
                tableView.beginUpdates()
                tableView.endUpdates()
                UIView.setAnimationsEnabled(true)
            }

            let auditAnswer = self.viewModel.currentAnswer
            cell.setup(answer: auditAnswer)
            cell.onChangeSelection = { [weak self] (selected) in
                let answerId = selected.first?.identifier
                self?.viewModel.setupCurrentAnswerValue(answerId)
//                auditAnswer?.responseTime += selected.first?.identifier
//                auditAnswer?.comment = ""
                self?.refreshUI()
            }
            cell.selectionStyle = .none
            return cell
        case .comment(let comment):
            let cell = tableView.dequeCell(at: indexPath) as AuditCommentTableViewCell
            cell.setup(with: comment)
            return cell
        case .media(let question, let index, let urls):
            let cell = tableView.dequeCell(at: indexPath) as AuditTilesTableViewCell
            cell.setup(with: urls, auditQuestion: question)

            cell.onPressAddPhotoButton = {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = true
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true, completion: nil)
            }
            return cell
        case .input(let question, let index):
            let cell = tableView.dequeCell(at: indexPath) as AuditInputTableViewCell
            cell.setup(with: question)

            let auditAnswer = self.viewModel.currentAnswer
            cell.setup(answer: auditAnswer)
            cell.onChange = { (text) in
                self.viewModel.setupCurrentAnswerComment(text)
            }
            cell.onPressSend = { (text) in
                self.viewModel.setupCurrentAnswerComment(text)
                if let text = text {
                    self.sendComment(text,
                                     questionId: question.identifier,
                                     at: self.viewModel.audit)
                }
            }
            return cell
        case .space(let height):
            let cell = tableView.dequeCell(at: indexPath) as AuditSpaceTableViewCell
            cell.setupHeight(height)
            return cell
        }
    }

    private func sendImage(_ image: UIImage?) {
        let imageMaxSide = Constants.imageUploadMaxSide
        guard let resized = image?.resize(toMaxSide: imageMaxSide),
            let questionIndex = self.viewModel.questionIndex else {
            showError(.incorrectInputData, onRetry: nil)
            return
        }

        FilesService.saveImage(resized,
                               success: { (remoteFile) in
                                self.viewModel.addMedia(remoteFile: remoteFile,
                                                        for: questionIndex)
                                self.tableView.reloadData()
        },
                               failure: { (error) in
                                self.showError(error, onRetry: nil)
        })
    }

    private func sendComment(_ text: String,
                             questionId: String?,
                             at audit: Audit?) {
        guard let auditId = audit?.identifier,
            let questionId = questionId else {
                showErrorMessage(forError: NetworkError.incorrectInputData)
                return
        }

        let comment = Comment(text: text,
                              objectId: auditId,
                              objectType: .answer,
                              meta: Comment.Meta(questionId: questionId))
        showProgressIndicator()
        CommentsService.sendComment(comment: comment,
                                    success: {
                                        self.hideProgressIndicator()
        },
                                    failure: { (error) in
                                        self.hideProgressIndicator()
                                        self.showErrorMessage(forError: error)
        })
    }

    private func sendAnswers(answers: [AuditAnswer],
                             for audit: Audit?) {
        guard let auditId = audit?.identifier,
            let libraryId = audit?.libraryId else {
                showError(NetworkError.incorrectInputData, onRetry: nil)
                return
        }

        showProgressIndicator()
        let success: (() -> Void) = { [weak self] in
            self?.hideProgressIndicator()
        }
        let failure: ((NetworkError) -> Void) = { [weak self] error in
            self?.hideProgressIndicator()
            self?.showError(error, onRetry: nil)
        }

        AuditService.sendAnswers(answers,
                                 auditId: auditId,
                                 libraryId: libraryId,
                                 success: success,
                                 failure: failure)
    }

    private func updateTableInset(bottomInset: CGFloat) {
        self.tableView.contentInset.bottom = bottomInset
    }

    private func loadComments(forQuestion: AuditQuestion?, in audit: Audit?) {
        guard let auditId = audit?.identifier,
            let questionId = forQuestion?.identifier else {
                return
        }

        let pageToLoad = self.viewModel.currentQuestionComments?.meta?.nextPage ?? 1
        CommentsService.getAuditComments(objectId: auditId,
                                         questionId: questionId,
                                         page: pageToLoad,
                                         success: { (bundle) in
                                            self.viewModel.addComments(bundle: bundle)
                                            if self.isViewLoaded {
                                                self.tableView.reloadData()
                                            }
        },
                                         failure: { (error) in
                                            self.showErrorMessage(forError: error)
        })
    }
}

extension AuditQuestionViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension AuditQuestionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            sendImage(image)
        } else if let image = info[.originalImage] as? UIImage {
            sendImage(image)
        }

        picker.dismiss(animated: true, completion: nil)
    }
}

//
//  AuditDetailsViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 19.02.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import UIKit

class AuditDetailsViewController: BaseViewController, KeyboardObserver {

    private var viewModel = AuditDetailsViewModel(audit: nil)

    @IBOutlet private weak var segmentedHeader: SegmentedHeaderView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var questionSelectContainer: UIView!
    @IBOutlet private weak var previousButton: CustomButton!
    @IBOutlet private weak var nextButton: CustomButton!

    @IBOutlet private weak var statusStackView: UIStackView!
    @IBOutlet private weak var reworkActionContainer: UIView!
    @IBOutlet private weak var reworkButton: CustomButton!
    @IBOutlet private weak var rejectActionContainer: UIView!
    @IBOutlet private weak var rejectButton: CustomButton!
    @IBOutlet private weak var acceptActionContainer: UIView!
    @IBOutlet private weak var acceptButton: CustomButton!

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

        reloadAudit(withId: self.viewModel.audit?.identifier, showIndicator: true)
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toAuditQuestionViewController":
            if let destinationVC = segue.destination as? AuditQuestionViewController,
                let auditData = sender as? (Audit, Int) {
                destinationVC.configureWith(audit: auditData.0,
                                            questionIndex: auditData.1)
            }
        default:
            break
        }
    }

    override func localizeUI() {
        super.localizeUI()

        setupSegmentedHeaderView(header: self.segmentedHeader)
        setupHeaderTitle(text: self.viewModel.audit?.name)

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
//    @objc private func refreshDetails(sender: UIRefreshControl) {
//        reloadAudit(withId: self.viewModel.audit?.identifier,
//                    showIndicator: false,
//                    completion: {
//                        sender.endRefreshing()
//        })
//    }

    @IBAction func didPressPreviousButton(_ sender: Any) {
        if self.viewModel.currentQuestion?.userAnswer?.answer == nil,
            let answer = self.viewModel.currentAnswer {
                sendAnswers(answers: [answer], for: self.viewModel.audit)
        }
        
        guard let index = self.viewModel.questionIndex else { return }

        configureWith(questionIndex: index - 1)
    }

    @IBAction func didPressNextButton(_ sender: Any) {
        if self.viewModel.currentQuestion?.userAnswer?.answer == nil,
            let answer = self.viewModel.currentAnswer {
                sendAnswers(answers: [answer], for: self.viewModel.audit)
        }

        guard let index = self.viewModel.questionIndex else { return }

        configureWith(questionIndex: index + 1)
    }

    @IBAction func didPressReworkActionButton(_ sender: Any) {
        changeStatus(.onRework,
                     withComment: String(),
                     forAudit: self.viewModel.audit)
    }

    @IBAction func didPressRejectActionButton(_ sender: Any) {
        let alert = UIAlertController(title: Localization.string("audit.details.action.reject"),
                                      message: Localization.string("audit.details.enter_comment"),
                                      preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .default
            textField.placeholder = Localization.string("audit.details.input.placeholder")
            textField.text = nil
        }
        alert.addAction(UIAlertAction(
            title: Localization.string("common.ok"),
            style: .default,
            handler: { [unowned self, unowned alert] _ in
                let comment = alert.textFields?.first?.text
                self.changeStatus(.failedCommented,
                                  withComment: comment,
                                  forAudit: self.viewModel.audit)
        }))
        alert.addAction(UIAlertAction(title: Localization.string("common.cancel"),
                                      style: .cancel,
                                      handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func didPressAcceptActionButton(_ sender: Any) {
        guard let role = self.viewModel.audit?.role else { return }

        switch role {
        case .executor:
            changeStatus(.onControl,
                         withComment: String(),
                         forAudit: self.viewModel.audit)
        case .checking:
            changeStatus(.accepted,
                         withComment: String(),
                         forAudit: self.viewModel.audit)
        }
    }

    @objc private func sendAnswer(sender: Any) {
        var result = self.viewModel.allAnswers
//        for i in 0..<result.count {
//            // !!!!!!! remove it later
//            result[i].responseTime = 10
//        }
        sendAnswers(answers: result,
                    for: self.viewModel.audit)
    }

    // MARK: - Public
    public func configureWithAudit(_ newAudit: Audit) {
        self.viewModel = AuditDetailsViewModel(audit: newAudit)
        self.viewModel.resetDataForCurrentTab()
        self.title = newAudit.name
       
        if self.isViewLoaded {
            self.tableView.reloadData()
        }
    }

    // MARK: - Private
    private func configureAuditDetailsUI() {
        self.tableView.backgroundColor = AppStyle.Color.backgroundSecondary
        self.tableView.estimatedRowHeight = 48
        self.questionSelectContainer.isHidden = true

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

        setupStatusButtons(forAudit: self.viewModel.audit)
    }

    private func setupStatusButtons(forAudit: Audit?) {
        guard let status = forAudit?.status,
                let role = forAudit?.role else {
                    self.acceptActionContainer.isHidden = true
                    self.reworkActionContainer.isHidden = true
                    self.rejectActionContainer.isHidden = true
                    return
        }

        self.reworkButton.setTitle(Localization.string("audit.details.action.rework"), for: .normal)
        self.reworkButton.backgroundColor = .red
        self.rejectButton.setTitle(Localization.string("audit.details.action.reject"), for: .normal)
        self.rejectButton.backgroundColor = .red
        [self.acceptButton, self.reworkButton, self.reworkButton]
            .compactMap({ $0 }).forEach { (button) in
                AppStyle.setupShadow(forContainer: button)
                button.setTitleColor(AppStyle.Color.buttonSupplementary, for: .normal)
            }

        switch role {
        case .executor:
            self.acceptButton.setTitle(Localization.string("audit.details.action.send"), for: .normal)
            self.acceptButton.backgroundColor = AppStyle.Color.auditAccept
            self.acceptActionContainer.isHidden = (status != .assigned) && (status != .onRework)
            self.reworkActionContainer.isHidden = true
            self.rejectActionContainer.isHidden = true
        case .checking:
            self.acceptButton.setTitle(Localization.string("audit.details.action.accept"), for: .normal)
            self.acceptButton.backgroundColor = AppStyle.Color.auditAccept
            self.acceptActionContainer.isHidden = (status != .onControl)
            self.reworkActionContainer.isHidden = (status != .onControl)
            self.rejectActionContainer.isHidden = (status != .onControl)
        }
    }

    private func setupSegmentedHeaderView(header: SegmentedHeaderView) {
        let titles = self.viewModel.availableTabs.compactMap({ $0.title })
        header.backgroundColor = AppStyle.Color.backgroundMain
        header.setupSegments(
            withTitles: titles,
            selectedIndex: self.viewModel.selectedTab.rawValue,
            handler: { [weak self] (index) in
                guard let vm = self?.viewModel else { return }
                let tab = vm.availableTabs[index]
                vm.selectedTab = tab
                self?.configureUI(forTab: tab)
            })
        header.resetInsets(.zero)

        configureUI(forTab: self.viewModel.selectedTab)
    }

    private func configureUI(forTab: AuditUI.Tab) {
        switch forTab {
        case .list:
            self.questionSelectContainer.isHidden = true
            self.statusStackView.isHidden = true
        case .photo:
            self.questionSelectContainer.isHidden = false
            self.statusStackView.isHidden = true
        case .result:
            self.questionSelectContainer.isHidden = true
            self.statusStackView.isHidden = false
        }

        self.viewModel.resetDataForTab(forTab)
        switch forTab {
        case .photo:
            self.configureWith(questionIndex: 0)
        default:
            self.tableView.reloadData()
        }
    }

    private func openTab(_ tab: AuditUI.Tab) {
        if let tabIndex = self.viewModel.availableTabs.firstIndex(of: tab) {
            self.segmentedHeader.selectSegment(atIndex: Int(tabIndex))
        }
        configureUI(forTab: tab)
    }

    private func showSettings() {
        let actionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)

        let groupAction = UIAlertAction(
            title: Localization.string("audit.details.option.group"),
            style: .default,
            color: AppStyle.Color.textMain,
            handler: { [weak self] _ in
                if let currentValue = self?.viewModel.shouldGroupQuestions {
                    self?.viewModel.shouldGroupQuestions = !currentValue
                }
                if let audit = self?.viewModel.audit {
                    self?.configureWithAudit(audit)
                }
            })
        groupAction.setValue(self.viewModel.shouldGroupQuestions, forKey: "checked")
        actionSheet.addAction(groupAction)

        let hideAction = UIAlertAction(
            title: Localization.string("audit.details.option.hide_received"),
            style: .default,
            color: AppStyle.Color.textMain,
            handler: { [weak self] _ in
                if let currentValue = self?.viewModel.shouldHideReceived {
                    self?.viewModel.shouldHideReceived = !currentValue
                }
                // TODO: update data
            })
        hideAction.setValue(self.viewModel.shouldHideReceived, forKey: "checked")
        actionSheet.addAction(hideAction)

        actionSheet.addAction(UIAlertAction(title: Localization.string("common.cancel"),
                                            style: .cancel,
                                            color: AppStyle.Color.textMain,
                                            handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }

    private func reloadAudit(withId auditId: String?,
                             showIndicator: Bool,
                             completion: (() -> Void)? = nil) {
        guard let auditId = auditId else {
            completion?()
            return
        }

        let success: ((Audit) -> Void) = { [weak self] (loadedAudit) in
            self?.configureWithAudit(loadedAudit)
            completion?()
        }
        let failure: ((NetworkError) -> Void) = { [weak self] (error) in
            self?.showError(error, onRetry: nil)
            completion?()
        }
        AuditService.getAudit(auditId: auditId, success: success, failure: failure)
    }

    private func openAudit(_ audit: Audit?, withQuestion: AuditQuestion) {
        let questionsList = AuditHelper.questionsList(from: audit)
        guard let audit = audit,
            let index = questionsList?.firstIndex(where: {
                $0.identifier == withQuestion.identifier
            }) else {
                return
        }
        self.performSegue(withIdentifier: "toAuditQuestionViewController",
                          sender: (audit, index))
    }

    private func configureWith(questionIndex: Int) {
        self.viewModel.setupQuestionIndex(questionIndex)

//        self.loadComments(forQuestion: self.viewModel.currentQuestion,
//                          in: self.viewModel.audit)

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

extension AuditDetailsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.sections[section].rows.count
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
        // TODO: change here
        let row = self.viewModel.sections[indexPath.section].rows[indexPath.row]
        let cell = getQuestionTableViewCell(in: tableView, at: indexPath, row: row)
        cell.selectionStyle = .none

        // TYPE 1
//        let cell = getQuestionTableViewCell(in: tableView, at: indexPath)
//        let group = self.audit?.groupedQuestions?[indexPath.section]
//        if let questions = group?.questions {
//            cell.setup(with: questions[indexPath.row])
//        }

        // TYPE 2
//        if let allQuestions = self.audit?.groupedQuestions?
//                .compactMap({ $0.questions })
//                .flatMap({ $0 }),
//            allQuestions.count > indexPath.row {
//                cell.setup(with: allQuestions[indexPath.row])
//        }


        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let row = self.viewModel.sections[indexPath.section].rows[indexPath.row]
        switch row {
        case .title:
//            openAudit(self.viewModel.audit, withQuestion: question)
            if self.viewModel.selectedTab == .list {
                openTab(AuditUI.Tab.photo)
            }
        default:
            break
        }
    }

    // MARK: - Private
    private func refreshUI() {
        let isAuditCompleted = (self.viewModel.allAnswers.count == self.viewModel.sections.count)
            && !self.viewModel.allAnswers.contains(where: {
                $0.answer == nil
            })
        self.sendButton.isEnabled = isAuditCompleted
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
            cell.setup(with: urls, selectedIndex: nil, auditQuestion: question)

            cell.onPressAddPhotoButton = {
                let picker = CustomImagePickerController()
                picker.userInfo = [CustomImagePickerController.Key.Index: index]
                picker.delegate = self
                picker.allowsEditing = true
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true, completion: nil)
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

            if question.userAnswer?.answer == nil {
                let auditAnswer = self.viewModel.allAnswers[index]
                cell.setup(answer: auditAnswer)
            }
            cell.onChangeSelection = { [weak self] (selected) in
                let answerId = selected.first?.identifier
                self?.viewModel.setupAnswerValue(answerId, atIndex: index)
//                auditAnswer?.responseTime += selected.first?.identifier
//                auditAnswer?.comment = ""
                self?.refreshUI()
            }
            cell.selectionStyle = .none
            return cell
        case .media(let question, let index, let urls):
            let cell = tableView.dequeCell(at: indexPath) as AuditTilesTableViewCell
            cell.setup(with: urls, auditQuestion: question)

            cell.onPressAddPhotoButton = {
                let picker = CustomImagePickerController()
                picker.userInfo = [CustomImagePickerController.Key.Index: index]
                picker.delegate = self
                picker.allowsEditing = true
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true, completion: nil)
            }
            return cell
        case .comment(let comment):
            let cell = tableView.dequeCell(at: indexPath) as AuditCommentTableViewCell
            cell.setup(with: comment)
            return cell
        case .input(let question, let index):
            let cell = tableView.dequeCell(at: indexPath) as AuditInputTableViewCell
            cell.setup(with: question)

            var auditAnswer: AuditAnswer?
            auditAnswer = self.viewModel.allAnswers[index]
            cell.setup(answer: auditAnswer)
            cell.onChange = { (text) in
                self.viewModel.setupAnswerComment(text, atIndex: index)
            }
            cell.onPressSend = { (text) in
                self.viewModel.setupAnswerComment(text, atIndex: index)
                if let text = text,
                    let answer = auditAnswer {
                        auditAnswer?.comment = text
                        self.sendComment(text,
                                         questionId: answer.questionId,
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

    private func sendImage(_ image: UIImage?, forQuestionIndex: Int?) {
        let imageMaxSide = Constants.imageUploadMaxSide
        guard let resized = image?.resize(toMaxSide: imageMaxSide),
            let questionIndex = forQuestionIndex else {
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

//            self?.changeStatus(.onCheck, withComment: nil, forAudit: self?.viewModel.audit)
            if self?.isViewLoaded == true {
                self?.tableView.reloadData()
            }
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

    private func loadCommentsForQuestion(atIndex: Int, in audit: Audit?) {
        guard let auditId = audit?.identifier,
            let questionId = self.viewModel.allAnswers[atIndex].questionId else {
                return
        }

        let pageToLoad = self.viewModel.questionComments(atIndex: atIndex)?.meta?.nextPage ?? 1
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

    private func changeStatus(_ status: Audit.Status,
                              withComment: String?,
                              forAudit: Audit?) {
        guard let auditId = forAudit?.identifier else {
            return
        }

        let success: () -> Void = { [weak self] in
            self?.closeModule()
        }
        let failure: (NetworkError) -> Void = { [weak self] (error) in
            self?.showErrorMessage(forError: error)
        }
        AuditService.changeStatus(auditId: auditId,
                                  status: status,
                                  comment: withComment ?? String(),
                                  success: success,
                                  failure: failure)
    }
}

extension AuditDetailsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension AuditDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let customPicker = picker as? CustomImagePickerController
        let index = customPicker?.userInfo[CustomImagePickerController.Key.Index] as? Int
        if let image = info[.editedImage] as? UIImage {
            sendImage(image, forQuestionIndex: index)
        } else if let image = info[.originalImage] as? UIImage {
            sendImage(image, forQuestionIndex: index)
        }

        picker.dismiss(animated: true, completion: nil)
    }
}

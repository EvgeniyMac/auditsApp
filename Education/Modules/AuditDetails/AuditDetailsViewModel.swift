//
//  AuditDetailsViewModel.swift
//  Education
//
//  Created by Andrey Medvedev on 21.03.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import Foundation

class AuditDetailsViewModel {

    let availableTabs: [AuditUI.Tab] = [.list, .photo, .result]
    let audit: Audit?

    var sections = [AuditUI.Question]()
    var shouldGroupQuestions = true
    var shouldHideReceived = false

    var selectedTab = AuditUI.Tab.list {
        didSet {
            guard let index = self.questionIndexValue else { return }

            resetSectionsArray(forQuestionIndex: index,
                               tab: self.selectedTab)
        }
    }
    var selectedTabIndex: Int {
        return self.availableTabs.index(of: self.selectedTab) ?? Int.zero
    }

    private var data = [AuditQuestionData]()

//    private var sectionsArray = [AuditUI.Row]()
//    var sectionsList: [AuditUI.Row] {
//        return sectionsArray
//    }

    private var questionIndexValue: Int?
    var questionIndex: Int? {
        return questionIndexValue
    }

    var currentSelectedPreviewImageIndex: Int? {
        guard let index = self.questionIndexValue,
            index < self.data.count else {
                return nil
        }
        return self.data[index].selectedPreviewImageIndex
    }

    var currentQuestion: AuditQuestion? {
        guard let index = self.questionIndexValue,
            index < self.data.count else {
                return nil
        }
        return self.data[index].question
    }

    var currentAnswer: AuditAnswer? {
        guard let index = self.questionIndexValue,
            index < self.data.count else {
                return nil
        }
        return self.data[index].answer
    }

    var allAnswers: [AuditAnswer] {
        return self.data.map({ $0.answer })
    }

    var currentQuestionComments: CommentsBundle? {
        guard let index = self.questionIndexValue,
            index < self.data.count else {
                return nil
        }
        return self.data[index].comments
    }

    var hasPreviousQuestion: Bool {
        guard let index = self.questionIndex else {
            return false
        }
        return index > Int.zero
    }

    var hasNextQuestion: Bool {
        guard let index = self.questionIndex else {
            return false
        }
        return (index + 1) < self.data.count
    }

    var isReadyToSend: Bool {
        return !self.data.contains(where: {
            $0.answer.answer == nil
        })
    }

    // MARK: - Public
    init(audit: Audit?) {
        self.audit = audit
        let list = AuditHelper.questionsList(from: audit) ?? []
        self.data = list.map({ (question) -> AuditQuestionData in
            AuditQuestionData(commentsData: CommentsBundle(),
                              questionData: question,
                              answerData: AuditAnswer(question: question),
                              previewImageIndex: nil)
        })
    }

    func resetDataForCurrentTab() {
        resetDataForTab(self.selectedTab)
    }

    func resetDataForTab(_ tab: AuditUI.Tab) {
        switch tab {
        case .list:
            setupAllQuestions()
        case .photo:
            setupQuestionIndex(self.questionIndex ?? 0)
        case .result:
            setupResultRows()
        }
    }

    func setupAllQuestions() {
        var questionsList = [AuditUI.Question]()
        var questionIndex = Int.zero
        for group in self.audit?.groupedQuestions ?? [] {
            guard let questions = group.questions,
                !questions.isEmpty else {
                    continue
            }

            var sectionTitleRow: AuditUI.Row?
            if self.shouldGroupQuestions,
                let groupName = group.name {
                    sectionTitleRow = .groupTitle(text: groupName)
            }

            var list = questions.compactMap { (question) -> AuditUI.Question? in
                var questionRows = [AuditUI.Row]()
                if let row = sectionTitleRow {
                    sectionTitleRow = nil
                    questionRows.append(row)
                }

                questionRows.append(.space(height: 15))
                questionRows.append(.title(question: question))
                if question.imageUrl != nil {
                    questionRows.append(.image(question: question))
                }
                if let questionType = question.questionType {
                    switch questionType {
                    case .trueFalse:
                        questionRows.append(.options(question: question, index: questionIndex))
                    }
                }
                if question.canSendAnyMedia {
                    let questionData = self.data[questionIndex]
                    let sentPhotos = questionData.question.userAnswer?.media?.photos
                    let urls = sentPhotos ?? questionData.answer.media.photos
                    questionRows.append(.media(question: question,
                                               index: questionIndex,
                                               images: urls))
                }
                questionRows.append(.input(question: question, index: questionIndex))

                questionIndex += 1

                return AuditUI.Question(rows: questionRows)
            }

            if self.shouldGroupQuestions,
                let lastQuestion = list.last {
                // intergroup separator
                var rows = lastQuestion.rows
                rows.append(AuditUI.Row.space(height: 15))
                let question = AuditUI.Question(rows: rows)
                list.removeLast()
                list.append(question)
            }

            questionsList.append(contentsOf: list)
        }

        self.sections.removeAll()
        self.sections.append(contentsOf: questionsList)
    }

    func setupQuestionIndex(_ index: Int) {
        self.questionIndexValue = index
        resetSectionsArray(forQuestionIndex: index,
                           tab: self.selectedTab)
    }

    func setupResultRows() {
        self.sections.removeAll()
    }

    func questionComments(atIndex: Int) -> CommentsBundle? {
        return self.data[atIndex].comments
    }

    func setupAnswerComment(_ text: String?, atIndex: Int) {
        self.data[atIndex].answerData.comment = text
    }

    func setupCurrentAnswerComment(_ text: String?) {
        guard let index = self.questionIndexValue,
            index < self.data.count else {
                return
        }
        setupAnswerComment(text, atIndex: index)
    }

    func setupAnswerValue(_ answer: String?, atIndex: Int) {
        self.data[atIndex].answerData.answer = answer
    }

    func setupCurrentAnswerValue(_ answer: String?) {
        guard let index = self.questionIndexValue,
            index < self.data.count else {
                return
        }
        setupAnswerValue(answer, atIndex: index)
    }

    func addComments(bundle: CommentsBundle?) {
        guard let index = self.questionIndexValue,
            index < self.data.count else {
                return
        }

        guard let commentsList = bundle?.list,
            let commentsMeta = bundle?.meta else {
                return
        }

        let list = self.data[index].comments.list + commentsList
        let bundle = CommentsBundle(list: list, meta: commentsMeta)
        self.data[index].commentsData = bundle
        if let index = self.questionIndex {
            setupQuestionIndex(index)
        }
    }

    func addMedia(remoteFile: RemoteFile, for questionIndex: Int) {
        guard let url = remoteFile.url else { return }
        self.data[questionIndex].answerData.media.photos.append(url)
        resetDataForCurrentTab()
//        setupQuestionIndex(questionIndex)
//        setupAllQuestions()
    }

    func setSelectedPreviewImageIndex(indexValue: Int?) {
        guard let index = self.questionIndexValue,
            index < self.data.count else {
                return
        }

        self.data[index].previewImageIndex = indexValue
    }

    // MARK: - Private
    private func resetSectionsArray(forQuestionIndex index: Int,
                                    tab: AuditUI.Tab) {
        guard index >= 0, index < self.data.count else { return }

        self.sections.removeAll()
        switch tab {
        case .list:
            self.sections.append(sectionsArrayForListTab(questionIndex: index))
        case .photo:
            self.sections.append(sectionsArrayForPhotoTab(questionIndex: index))
        case .result:
            break
        }
    }

    private func sectionsArrayForListTab(questionIndex index: Int) -> AuditUI.Question {
        var questionSection = [AuditUI.Row]()
        let question = data[index].question
        questionSection.append(.space(height: 15))
        questionSection.append(.title(question: question))
        if question.imageUrl != nil {
            questionSection.append(.image(question: question))
        }
        if let questionType = question.questionType {
            switch questionType {
            case .trueFalse:
                questionSection.append(.options(question: question, index: index))
            }
        }
        if question.canSendAnyMedia {
            let questionData = self.data[index]
            let sentPhotos = questionData.question.userAnswer?.media?.photos
            let urls = sentPhotos ?? questionData.answer.media.photos
            questionSection.append(.media(question: question, index: index, images: urls))
        }

        let comments = self.data[index].comments.list
        let commentRows = comments.map({ AuditUI.Row.comment(comment: $0) })
        questionSection.append(contentsOf: commentRows)

        questionSection.append(.input(question: question, index: index))
        return AuditUI.Question(rows: questionSection)
    }

    private func sectionsArrayForPhotoTab(questionIndex index: Int) -> AuditUI.Question {
        var questionSection = [AuditUI.Row]()
        let question = self.data[index].question
        questionSection.append(.space(height: 15))

        let questionData = self.data[index]
        let sentPhotos = questionData.question.userAnswer?.media?.photos
        let urls = sentPhotos ?? questionData.answer.media.photos
        questionSection.append(.imagesPreview(question: question,
                                              index: index,
                                              images: urls))

        questionSection.append(.title(question: question))
        if question.imageUrl != nil {
            questionSection.append(.image(question: question))
        }
        if let questionType = question.questionType {
            switch questionType {
            case .trueFalse:
                questionSection.append(.options(question: question, index: index))
            }
        }

        let comments = self.data[index].comments.list
        let commentRows = comments.map({ AuditUI.Row.comment(comment: $0) })
        questionSection.append(contentsOf: commentRows)

        questionSection.append(.input(question: question, index: index))
        return AuditUI.Question(rows: questionSection)
    }
}

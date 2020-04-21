//
//  ResultViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 08/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

protocol ResultViewOutput {
    func viewIsReady()
    func shouldMoveBack()
}

protocol ResultViewInput: class {
    func showProgressIndicator()
    func hideProgressIndicator()
    func showError(_ error: NetworkError,
                   onRetry: (() -> Void)?,
                   onDismiss: (() -> Void)?)

    func configureWith(questionnaire: Questionnaire?, course: Course?)
    func configureWith(courseResult: CourseResult?)
}

class ResultViewController: BaseViewController, ResultViewInput {

    var output: ResultViewOutput!

    var questionnaire: Questionnaire?
    var courseResult: CourseResult?
    var course: Course?

    @IBOutlet weak var statusPlaceholderView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var resultContainer: UIView!
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var resultTitleLabel: UILabel!
    @IBOutlet weak var resultSubtitleLabel: UILabel!
    @IBOutlet weak var rewardsView: RewardsView!

    @IBOutlet weak var topPlaceholderView: UIView!

    @IBOutlet weak var correctContainer: UIView!
    @IBOutlet weak var correctTitleLabel: UILabel!
    @IBOutlet weak var correctValueLabel: UILabel!

    @IBOutlet weak var timeContainer: UIView!
    @IBOutlet weak var timeTitleLabel: UILabel!
    @IBOutlet weak var timeValueLabel: UILabel!

    @IBOutlet weak var attemptsContainer: UIView!
    @IBOutlet weak var attemptsTitleLabel: UILabel!
    @IBOutlet weak var attemptsValueLabel: UILabel!

    @IBOutlet weak var ratingContainer: UIView!
    @IBOutlet weak var ratingTitleLabel: UILabel!
    @IBOutlet weak var ratingValueLabel: UILabel!

    @IBOutlet weak var supplementaryButtonsContainer: UIView!
    @IBOutlet weak var allAnswersButton: UIButton!
    @IBOutlet weak var myMistakesButton: UIButton!
    @IBOutlet weak var actionButton: CustomButton!

    @IBOutlet weak var statusPlaceholderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomPlaceholderHeightConstraint: NSLayoutConstraint!

    private let bottomPlaceholderHeightMax = CGFloat(25.0)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.output.viewIsReady()

        configureUI()
        localizeUI()
        updateWith(questionnaire: self.questionnaire, course: self.course)
        setupCourseResult(self.courseResult, forCourse: self.course)
    }

    override func localizeUI() {
        super.localizeUI()

        self.correctTitleLabel.text = Localization.string("result.correct.title")
        self.timeTitleLabel.text = Localization.string("result.time.title")
        self.attemptsTitleLabel.text = Localization.string("result.attempts.title")
        self.ratingTitleLabel.text = Localization.string("result.rating.title")

        let allAnswersTitle = Localization.string("result.all_answers.title")
        self.allAnswersButton.setTitle(allAnswersTitle, for: .normal)
        let myMistakesTitle = Localization.string("result.my_mistakes.title")
        self.myMistakesButton.setTitle(myMistakesTitle, for: .normal)

        updateWith(questionnaire: self.questionnaire, course: self.course)

        self.rewardsView.showDemoData()
    }

    override func shouldHideTabBar() -> Bool {
        return true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        let barView = BarActionView()
        barView.setupBarItem(withActions: [.settings])
        let barItem = UIBarButtonItem(customView: barView)
        self.navigationItem.rightBarButtonItems = [barItem]
    }

    override func shouldMoveBack() {
        self.output.shouldMoveBack()
    }

    // MARK: - ResultViewInput
    func configureWith(questionnaire: Questionnaire?, course: Course?) {
        self.questionnaire = questionnaire
        self.course = course

        QuestionnaireManager.shared.setQuestionnaire(questionnaire)

        updateWith(questionnaire: questionnaire, course: course)
        updateBottomPlaceholder()
    }

    func configureWith(courseResult: CourseResult?) {
        setupCourseResult(courseResult, forCourse: self.course)
        updateBottomPlaceholder()
    }

    // MARK: - Actions
    @IBAction private func didPressActionButton(_ sender: Any) {
        if let questionnaire = questionnaire,
            !questionnaire.isTestPassed() {
            if let remainingAttempts = questionnaire.material.remainingAttemptsCount,
                remainingAttempts <= 1 {
            } else {
                // Retry test
            }
        }

        self.output.shouldMoveBack()
    }

    // MARK: - Private
    private func updateWith(questionnaire: Questionnaire?, course: Course?) {
        if let questionnaire = questionnaire {
            setupQuestionnaire(questionnaire)
        }
        if let course = course {
            setupCourse(course)
        }
    }

    private func setupQuestionnaire(_ questionnaire: Questionnaire) {
        guard self.isViewLoaded else { return }

        let isTestPassed = questionnaire.isTestPassed()
        if isTestPassed {
            self.resultContainer.backgroundColor = AppStyle.Color.backgroundCorrect
            self.resultImageView.image = UIImage(named: "smile_result-correct_2")
            self.rewardsView.isHidden = false
            self.resultTitleLabel.text = Localization.string("result.test_passed_title")
            self.resultSubtitleLabel.text = Localization.string("result.test_passed_subtitle")
        } else {
            self.resultContainer.backgroundColor = AppStyle.Color.backgroundIncorrect
            self.resultImageView.image = UIImage(named: "smile_result-incorrect")
            self.rewardsView.isHidden = true
            self.resultTitleLabel.text = Localization.string("result.test_failed_title")
            self.resultSubtitleLabel.text = Localization.string("result.test_failed_subtitle")
        }

        setupAttemptsInfo(from: questionnaire, and: self.courseResult)

        let questionsTotal = questionnaire.questionsTotal
        let questionsCorrect = questionnaire.questionsCorrect
        let ofText = Localization.string("common.preposition_of")
        correctValueLabel.text = "\(questionsCorrect) \(ofText) \(questionsTotal)"
        timeValueLabel.text = questionnaire.getTotalAnswerTime().readableString()

        if let usedAttempts = questionnaire.course.stats?.usedAttemptsCount {
            attemptsValueLabel.text = String(usedAttempts)
            attemptsContainer.isHidden = false
        } else {
            attemptsContainer.isHidden = true
        }
    }

    private func isTestPassed(questionnaire: Questionnaire?,
                              courseResult: CourseResult?) -> Bool? {
        return courseResult?.isPassed ?? questionnaire?.isTestPassed()
    }

    private func setupAttemptsInfo(from questionnaire: Questionnaire?,
                                   and result: CourseResult?) {
        guard questionnaire?.material.documentType == .exam else {
            attemptsContainer.isHidden = true
            return
        }

        if isTestPassed(questionnaire: questionnaire, courseResult: result) ?? false {
            if let attemptsMade = result?.attemptsMade {
                attemptsTitleLabel.text = Localization.string("result.attempts.title")
                attemptsValueLabel.text = String(attemptsMade)
                attemptsContainer.isHidden = false
            } else if let remainingAttempts = questionnaire?.material.remainingAttemptsCount,
                let totalAttempts = questionnaire?.course.attemptsCount {
                    attemptsTitleLabel.text = Localization.string("result.attempts.title")
                    attemptsValueLabel.text = String(totalAttempts - remainingAttempts + 1)
                    attemptsContainer.isHidden = false
            } else {
                attemptsContainer.isHidden = true
            }
        } else {
            if let remainingAttempts = questionnaire?.material.remainingAttemptsCount {
                attemptsTitleLabel.text = Localization.string("result.attempts_remaining.title")
                let attempts = max(remainingAttempts - 1, Int.zero)
                attemptsValueLabel.text = String(attempts)
                attemptsContainer.isHidden = false
            } else {
                attemptsContainer.isHidden = true
            }
        }
    }

    private func setupCourseResult(_ result: CourseResult?, forCourse: Course?) {
        if let ratingPlace = result?.ratingCurrentPlace,
            let ratingTotal = result?.ratingTotalPlace {
            ratingContainer.isHidden = false

            let ofText = Localization.string("common.preposition_of")
            let text = "\(ratingPlace) \(ofText) \(ratingTotal)"
            self.ratingValueLabel.text = text
        } else {
            ratingContainer.isHidden = true
        }

        // showing supplementary buttons for exams
        let showButtons = forCourse?.type == Course.CourseType.exam
        supplementaryButtonsContainer.isHidden = !showButtons

        setupAttemptsInfo(from: questionnaire, and: result)

        if let timeSpent = result?.timeSpent {
            timeValueLabel.text = TimeInterval(timeSpent).readableString()
            timeContainer.isHidden = false
        } else {
            timeContainer.isHidden = true
        }
    }

    private func setupCourse(_ course: Course) {
        guard self.isViewLoaded else { return }

        self.resultContainer.backgroundColor = AppStyle.Color.backgroundCorrect
        self.resultImageView.image = UIImage(named: "smile_result-correct_1")

        var isPassed = false
        if let status = course.stats?.status {
            switch status {
            case .passed, .overduePassed:
                isPassed = true
            default:
                isPassed = false
            }
        }
        self.resultTitleLabel.text = getTitle(forCourseType: course.type,
                                              isPassed: isPassed)
        self.resultSubtitleLabel.text = getSubtitle(forCourseType: course.type,
                                                    isPassed: isPassed)
        self.rewardsView.isHidden = false

        // TODO: show time container
        // TODO: find time value
        timeContainer.isHidden = true

        correctContainer.isHidden = true
        attemptsContainer.isHidden = true
        ratingContainer.isHidden = true
        supplementaryButtonsContainer.isHidden = true
    }

    private func updateBottomPlaceholder() {
        guard self.isViewLoaded else { return }
        DispatchQueue.main.async { [weak self] in
            self?.resizeBottomPlaceholder()
        }
    }

    private func resizeBottomPlaceholder() {
        let scrollViewHeight = self.scrollView.frame.height
        let scrollViewContentHeight = self.scrollView.contentSize.height
        let bottomPlaceholderHeight = self.bottomPlaceholderHeightConstraint.constant

        let space = scrollViewHeight - (scrollViewContentHeight - bottomPlaceholderHeight)
        let height = min(bottomPlaceholderHeightMax, max(space, CGFloat.zero))
        self.bottomPlaceholderHeightConstraint.constant = height
    }

    private func configureUI() {
        self.view.backgroundColor = AppStyle.Color.backgroundMain

        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        self.statusPlaceholderHeightConstraint.constant = statusBarHeight
        self.statusPlaceholderView.backgroundColor = AppStyle.Color.backgroundMain

        self.resultTitleLabel.textColor = AppStyle.Color.textMain
        self.resultTitleLabel.font = AppStyle.Font.semibold(24)
        self.resultSubtitleLabel.textColor = AppStyle.Color.textSupplementary
        self.resultSubtitleLabel.font = AppStyle.Font.regular(16)

        [self.correctTitleLabel,
         self.correctValueLabel,
         self.timeTitleLabel,
         self.timeValueLabel,
         self.attemptsTitleLabel,
         self.attemptsValueLabel,
         self.ratingTitleLabel,
         self.ratingValueLabel].forEach { (label) in
            label?.textColor = AppStyle.Color.textMain
            label?.font = AppStyle.Font.regular(16)
        }

        [self.allAnswersButton, self.myMistakesButton].forEach { (button) in
            button?.titleLabel?.font = AppStyle.Font.medium(14)
            button?.setTitleColor(AppStyle.Color.green, for: .normal)
        }

        var buttonTitle = Localization.string("result.button_proceed_title")
        if let questionnaire = questionnaire {
            if !questionnaire.isTestPassed() {
                if let remainingAttempts = questionnaire.material.remainingAttemptsCount,
                    remainingAttempts <= 1 {
                    // last attempt
                    buttonTitle = Localization.string("result.button_proceed_title")
                } else {
                    buttonTitle = Localization.string("result.button_retry_title")
                }
            }
        }
        self.actionButton.setTitle(buttonTitle, for: .normal)
    }

    private func getTitle(forCourseType: Course.CourseType?,
                          isPassed: Bool) -> String? {
        guard let type = forCourseType else {
            return nil
        }

        var titleKey: String
        switch type {
        case .exam:
            titleKey = isPassed
                ? "result.exam.correct.title" : "result.exam.incorrect.title"
        case .test:
            titleKey = isPassed
                ? "result.test.correct.title" : "result.test.incorrect.title"
        case .course:
            titleKey = isPassed
                ? "result.course.correct.title" : "result.course.incorrect.title"
        }
        return Localization.string(titleKey)
    }

    private func getSubtitle(forCourseType: Course.CourseType?,
                             isPassed: Bool) -> String? {
        guard let type = forCourseType else {
            return nil
        }

        var subtitleKey: String
        switch type {
        case .exam:
            subtitleKey = isPassed
                ? "result.exam.correct.subtitle" : "result.exam.incorrect.subtitle"
        case .test:
            subtitleKey = isPassed
                ? "result.test.correct.subtitle" : "result.test.incorrect.subtitle"
        case .course:
            subtitleKey = isPassed
                ? "result.course.correct.subtitle" : "result.course.incorrect.subtitle"
        }
        return Localization.string(subtitleKey)
    }
}

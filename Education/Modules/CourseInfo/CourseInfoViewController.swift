//
//  CourseInfoViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 23/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

protocol CourseInfoViewOutput {
    func viewIsReady()

    func setupWith(course: Course, onUpdate: (() -> Void)?)

    func openQuestions(for material: Material, from course: Course?)
    func openMaterial(_ material: Material, from course: Course?)
    func runCourse(_ course: Course?)

    func shouldUpdateCurrentCourse(course: Course?)
    func shouldAddBookmark(for course: Course?)
    func shouldRemoveBookmark(for course: Course?)
}

protocol CourseInfoViewInput: class {
    func configureWith(viewModel: CourseInfoViewModel?)
//    func updateWithCourse(_ course: Course?)

    func showProgressIndicator()
    func hideProgressIndicator()
    func showError(_ error: NetworkError,
                   onRetry: (() -> Void)?,
                   onDismiss: (() -> Void)?)
    func showErrorMessage(forError error: NetworkError)
}

class CourseInfoViewController: BaseViewController, CourseInfoViewInput {

    var output: CourseInfoViewOutput!

    private let kTitleAppearanceOffset = CGFloat(200)

    public lazy var segmentedHeader = self.createSegmentedHeaderView()

    @IBOutlet weak var tableView: UITableView!

    private var bookmarkButton: UIButton?

    var viewModel: CourseInfoViewModel? {
        didSet {
            if self.isViewLoaded {
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.output.viewIsReady()

        configureUI()
        configureTable()

        self.title = Localization.string("course_info.title")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        if let identifier = self.viewModel?.course.identifier {
//            loadCourse(identifier: identifier)
//        }
        self.output.shouldUpdateCurrentCourse(course: self.viewModel?.course)
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        let barView = BarActionView()
        barView.setupBarItem(withActions: [.bookmark, .settings])
        barView.onPressBookmark = { [weak self] (isBookmarked) in
            self?.handleCourseBookmark(isBookmarked: isBookmarked)
        }
        let barItem = UIBarButtonItem(customView: barView)
        self.navigationItem.rightBarButtonItems = [barItem]

        self.bookmarkButton = barView.bookmarkButton
        self.bookmarkButton?.isSelected = self.viewModel?.course.isBookmarked ?? false
    }

    // MARK: - CourseInfoViewInput
    func configureWith(viewModel: CourseInfoViewModel?) {
        self.viewModel = viewModel
    }

//    func updateWithCourse(_ course: Course?) {
//        guard let vm = self.viewModel,
//            let course = course else {
//                return
//        }
//
//        if course.stats?.status != vm.course.stats?.status {
//            NotificationCenter.default.post(name: .DidChangedCourseStatus,
//                                            object: nil)
//
//            if let unresolvedMaterials = course.materials?.filter({ !($0.isPassed ?? false) }),
//                unresolvedMaterials.isEmpty {
//                self.showCongratulations(course: course)
//            }
//        }
//
//        vm.setupCourse(course)
//    }

    // MARK: - Overrides
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toMaterialViewController" {
//            if let destinationVC = segue.destination as? MaterialViewController,
//                let material = sender as? Material {
//                destinationVC.material = material
//                destinationVC.course = self.viewModel?.course
//                destinationVC.onReadLesson = { [unowned self] (material, nextMaterialId) in
//                    if let identifier = self.viewModel?.course.identifier {
//                        self.loadCourse(identifier: identifier, completion: { [unowned self] in
//                            self.openMaterial(after: material, from: self.viewModel?.course)
//                        })
//                    }
//                }
//            }
//        } else if segue.identifier == "toQuestionViewController" {
//            if let destinationVC = segue.destination as? QuestionViewController,
//                let questionnaire = sender as? Questionnaire {
//                destinationVC.questionnaire = questionnaire
//            }
//        }
//    }
//
//    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//        if identifier == "toMaterialViewController" {
//            return sender is Material
//        } else if identifier == "toQuestionViewController" {
//            return sender is Questionnaire
//        }
//        return true
//    }

    // MARK: - Public
    public func setup(withCourse: Course) {
        self.bookmarkButton?.isSelected = withCourse.isBookmarked
        self.output.setupWith(
            course: withCourse,
            onUpdate: { [weak self] in
                self?.bookmarkButton?.isSelected = withCourse.isBookmarked
                self?.tableView.reloadData()
            })
    }

    // MARK: - Actions
    private func handleCourseBookmark(isBookmarked: Bool) {
        guard let vm = self.viewModel else { return }

        vm.course.isBookmarked = isBookmarked
        setupBookmarkState(isBookmarked: isBookmarked,
                           for: vm.course)
    }

    // MARK: - Private
    private func configureUI() {
        self.view.backgroundColor = AppStyle.Color.backgroundSecondary
    }

    private func configureTable() {
        [CourseInfoTableViewCell.self,
         CourseStatsTableViewCell.self,
         AppointmentChapterTableViewCell.self,
         AppointmentTestTableViewCell.self,
         ButtonTableViewCell.self,
         DoubleButtonTableViewCell.self,
         TextTableViewCell.self,
         TagsTableViewCell.self,
         RewardsTableViewCell.self]
            .forEach { [unowned self] (type) in
                type.registerNib(at: self.tableView)
        }
    }

//    private func showCongratulations(course: Course) {
//        let alert = UIAlertController(title: Localization.string("common.congratulations"),
//                                      message: course.getCongratulationsMessage(),
//                                      preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: Localization.string("congratulations.to_courses"),
//                                      style: .cancel,
//                                      color: AppStyle.Color.buttonMain,
//                                      handler: { [weak self] _ in
//                                        self?.navigationController?.popToRootViewController(animated: true)
//        }))
//        self.present(alert, animated: true, completion: nil)
//    }

    private func setupBookmarkState(isBookmarked: Bool,
                                    for course: Course) {
        self.bookmarkButton?.isSelected = isBookmarked
        if isBookmarked {
            self.output.shouldAddBookmark(for: course)
        } else {
            self.output.shouldRemoveBookmark(for: course)
        }

        // updating for previos view controllers
        NotificationCenter.default.post(name: .DidChangedCourseStatus,
                                        object: nil)
    }

    private func createSegmentedHeaderView() -> SegmentedHeaderView {
        guard let vm = self.viewModel else {
            return SegmentedHeaderView(frame: .zero)
        }

        let titles = vm.availableInfoTabs
            .compactMap({ (infoType) -> String? in
                return infoType.getTitle(for: vm.course.type)
            })

        let header = SegmentedHeaderView()
        header.backgroundColor = AppStyle.Color.backgroundMain
        header.setupSegments(withTitles: titles,
                             selectedIndex: 0,
                             handler: { (index) in
            let type = vm.availableInfoTabs[index]
            vm.selectedCourseInfoType = type
        })

        return header
    }
}

extension CourseInfoViewController: NotificationHandlerProtocol {
    func handlePushNotification() { }
}

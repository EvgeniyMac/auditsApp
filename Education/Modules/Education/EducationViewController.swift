//
//  EducationViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 01/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

enum CourseGroupType: Int, CaseIterable {
    case recommended = 0
    case mine
    case market

    var title: String {
        switch self {
        case .recommended:
            return Localization.string("education.group_recommended")
        case .mine:
            return Localization.string("education.group_my")
        case .market:
            return Localization.string("education.group_library")
        }
    }
}

class EducationViewController: BaseViewController {

    struct CoursesGroup {
        var type: CourseGroupType
        var courses: [Course] = []
        var totalCount: Int?
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topBarUnderView: UIView!

    private let kGroupRowOffsetTop = 1
    private var groups: [CoursesGroup] = {
        return CourseGroupType.allCases.map({ CoursesGroup(type: $0, courses: []) })
    }()

    private var courseChangeObserver: Any?
    private var appActiveObserver: Any?
    private var shouldUpdateOnAppear = false

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureTabBar()
        configureTable()
        localizeUI()

        subscribeToChangesNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // always updating on appear according to requirement(#13229)
        updateCoursesList(shouldShowIndicator: false, completion: nil)

        self.navigationItem.rightBarButtonItems?
            .forEach({ (item) in
                if let item = item.customView as? BarActionView {
                    item.reloadBarItem(withAction: .profile)
                }
            })
    }

    deinit {
        unsubscribeFromChangesNotifications()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toCoursesListViewController":
            if let destinationVC = segue.destination as? CoursesListViewController,
                let type = sender as? CourseGroupType {
                destinationVC.selectedCourseType = type
            }
        case "toCourseInfoViewController":
            if let destinationVC = segue.destination as? CourseInfoViewController,
                let course = sender as? Course {
                destinationVC.setup(withCourse: course)
            }
        default:
            break
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "toCoursesListViewController":
            return sender is CourseGroupType
        case "toCourseInfoViewController":
            return sender is Course
        default:
            return true
        }
    }

    override func localizeUI() {
        super.localizeUI()

        let titleText = Localization.string("education.navigation_bar_title")
        self.setupHeaderTitle(text: titleText)
        configureTabBar()

        if self.isViewLoaded {
            self.tableView.reloadData()
        }
    }

    override func openUserProfile() {
        self.performSegue(withIdentifier: "toProfile", sender: nil)
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        let barView = BarActionView()
        barView.setupBarItem(withActions: [.search, .profile, .settings])
        barView.onPressProfile = { [weak self] in
            self?.openUserProfile()
        }
        barView.onPressSettings = { [weak self] in
            self?.showPreferences()
        }
        let barItem = UIBarButtonItem(customView: barView)
        self.navigationItem.rightBarButtonItems = [barItem]
    }

//    override func handlePushNotification(data: [AnyHashable : Any]) {
//        if let courseId = NotificationManager.getAppointmentId(from: data) {
//            self.shouldUpdateOnAppear = true
//            showCourse(courseId: courseId)
//        } else if UIApplication.shared.applicationState == .active,
//            self.isTopmost() {
//            self.updateCoursesList(shouldShowIndicator: false,
//                                   completion: nil)
//        } else {
//            self.shouldUpdateOnAppear = true
//        }
//    }

    // MARK: - Actions
    @objc private func refreshOptions(sender: UIRefreshControl) {
        updateCoursesList(shouldShowIndicator: false,
                          completion: {
                            sender.endRefreshing()
        })
    }

    // MARK: - Private
    private func configureUI() {
        self.view.backgroundColor = AppStyle.Color.backgroundSecondary
        self.topBarUnderView.backgroundColor = AppStyle.Color.backgroundMain
    }

    private func configureTabBar() {
        self.tabBarItem.title = Localization.string("courses_list.tab_bar_title")
    }

    private func configureTable() {
        [CourseTableViewCell.self,
         HeaderTableViewCell.self]
            .forEach { [unowned self] (type) in
                type.registerNib(at: self.tableView)
        }

        self.tableView.separatorInset = AppStyle.Table.separatorInsets

        setupRefreshControl()
    }

    private func showCourse(courseId: String) {
        showProgressIndicator()
        CoursesService.loadCourse(courseId: courseId,
                                  success: { (course) in
                                    self.hideProgressIndicator()
                                    self.showCourse(course)
        },
                                  failure: { (error) in
                                    let onRetry: (() -> Void) = { [weak self] in
                                        self?.showCourse(courseId: courseId)
                                    }
                                    self.hideProgressIndicator()
                                    self.showError(error, onRetry: onRetry)
        })
    }

    private func showCourse(_ course: Course) {
        self.performSegue(withIdentifier: "toCourseInfoViewController", sender: course)
    }

    private func showCourses(type: CourseGroupType) {
        self.performSegue(withIdentifier: "toCoursesListViewController", sender: type)
    }

    private func updateCoursesList(shouldShowIndicator: Bool,
                                   completion: (() -> Void)?) {
        guard self.isViewLoaded else { return }

        let successHandler: ((CoursesBundle) -> Void) = { [weak self] (bundle) in
            self?.groups.removeAll()
            for type in CourseGroupType.allCases {
                switch type {
                case .recommended:
                    self?.groups.append(CoursesGroup(type: type,
                                                     courses: bundle.recommended,
                                                     totalCount: bundle.recommendedCount))
                case .mine:
                    self?.groups.append(CoursesGroup(type: type,
                                                     courses: bundle.mine,
                                                     totalCount: bundle.mineCount))
                case .market:
                    self?.groups.append(CoursesGroup(type: type,
                                                     courses: bundle.market,
                                                     totalCount: bundle.marketCount))
                }
            }

            self?.tableView.reloadData()
            if shouldShowIndicator {
                self?.hideProgressIndicator()
            }

            if let stats = bundle.stats {
                CommonInfoRepo.shared.updateCommonStats(stats)
            }

            completion?()
        }
        let failureHandler: ((NetworkError) -> Void) = { [weak self] (error) in
            if shouldShowIndicator {
                self?.hideProgressIndicator()
            }
            let onRetry: (() -> Void) = { [weak self] in
                self?.updateCoursesList(shouldShowIndicator: shouldShowIndicator,
                                        completion: completion)
            }
            self?.showError(error, onRetry: onRetry)
            completion?()
        }


        if shouldShowIndicator {
            showProgressIndicator()
        }
        CoursesService.loadRecommendedAndMarketCourses(success: successHandler,
                                                       failure: failureHandler)
    }

    private func showPreferences() {
        let actionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        let completedTitle = Localization.string("prefs.completed")
        actionSheet.addAction(UIAlertAction(title: completedTitle,
                                            style: .default,
                                            color: AppStyle.Color.textMain,
                                            handler: { _ in }))
        let cancelTitle = Localization.string("prefs.cancel")
        actionSheet.addAction(UIAlertAction(title: cancelTitle,
                                            style: .cancel,
                                            color: AppStyle.Color.textMain,
                                            handler: { _ in }))
        self.present(actionSheet, animated: true, completion: nil)
    }

    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = AppStyle.Color.main
        refreshControl.addTarget(self,
                                 action: #selector(refreshOptions(sender:)),
                                 for: .valueChanged)
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControl
        } else {
            self.tableView.addSubview(refreshControl)
        }
    }

    // MARK: - Notifications
    private func subscribeToChangesNotifications() {
        self.courseChangeObserver = NotificationCenter.default
            .addObserver(forName: .DidChangedCourseStatus,
                         object: nil,
                         queue: nil) { [unowned self] _ in
                            self.shouldUpdateOnAppear = true
        }
        self.appActiveObserver = NotificationCenter.default
            .addObserver(forName: UIApplication.didBecomeActiveNotification,
                         object: nil,
                         queue: nil) { [weak self] _ in
                            if self?.shouldUpdateOnAppear == true,
                                self?.isTopmost() == true {
                                self?.updateCoursesList(shouldShowIndicator: false,
                                                        completion: nil)
                            }
        }
    }

    private func unsubscribeFromChangesNotifications() {
        if let observer = courseChangeObserver {
            courseChangeObserver = nil
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = appActiveObserver {
            appActiveObserver = nil
            NotificationCenter.default.removeObserver(observer)
        }
    }

}

extension EducationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let group = self.groups[indexPath.section]
        let courseIndex = indexPath.row - kGroupRowOffsetTop
        if courseIndex >= 0 {
            showCourse(group.courses[courseIndex])
        }
    }
}

extension EducationViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.groups.compactMap({ !$0.courses.isEmpty }).count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        let courses = self.groups[section].courses
        if !courses.isEmpty {
            let visible = courses.count//min(courses.count, kGroupItemsVisibleMax)
            return kGroupRowOffsetTop + visible
        }
        return .zero
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let group = self.groups[indexPath.section]
        if indexPath.row == .zero {
            return createHeaderCell(tableView: tableView,
                                    indexPath: indexPath,
                                    group: group)
        } else {
            let courseIndex = indexPath.row - kGroupRowOffsetTop
            let course = group.courses[courseIndex]
            return createCourseCell(tableView: tableView,
                                    indexPath: indexPath,
                                    course: course)
        }
    }

    // MARK: - Private
    private func createHeaderCell(tableView: UITableView,
                                  indexPath: IndexPath,
                                  group: CoursesGroup) -> HeaderTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: HeaderTableViewCell.reuseIdentifier(),
            for: indexPath) as? HeaderTableViewCell else {
                fatalError("Unable to create HeaderTableViewCell")
        }

        var actionTitle: String?
        if !group.courses.isEmpty {
            let text = Localization.string("education.group_action")
            if let count = group.totalCount {
                actionTitle = "\(text) \(count)"
            } else {
                actionTitle = text
            }
        }

        cell.setupWith(title: group.type.title,
                       actionTitle: actionTitle,
                       action: { [weak self] in
                        self?.showCourses(type: group.type)
        })

        // clippting top for HeaderTableViewCell in the first section
        cell.isClippedTop = (indexPath.section == 0)

        cell.selectionStyle = .none

        return cell
    }

    private func createCourseCell(tableView: UITableView,
                                  indexPath: IndexPath,
                                  course: Course?) -> CourseTableViewCell {
        let cell: CourseTableViewCell = tableView.dequeCell(at: indexPath)
        TableCellStyle.apply(to: cell, course: course)

        // clippting top for the first CourseTableViewCell in section
        cell.isClippedTop = (indexPath.row == kGroupRowOffsetTop)

        return cell
    }
}

extension EducationViewController: NotificationHandlerProtocol {
    func handlePushNotification() {
        self.shouldUpdateOnAppear = true
    }
}

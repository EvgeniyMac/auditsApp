//
//  CoursesListViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 17/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class CoursesListViewController: BaseViewController {

    private struct PagingState {
        let perPage = 20

        var pageNumber = 1
        var isLoading = false
        var isLoadedLastPage = false
    }

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var topBarUnderView: UIView!
    @IBOutlet var courseCompilationsStackView: UIStackView!
    @IBOutlet weak var recommendedContainerView: UIView!
    @IBOutlet weak var randomContainerView: UIView!

    public var selectedCourseType = CourseGroupType.recommended {
        didSet {
            self.reloadCoursesFromStart(showIndicator: true)
        }
    }
    private var courses = [Course]()
    private var pagingState = PagingState()

    private var selectedCourseId: String?
    private let titleCenterLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppStyle.Color.textMain
        label.font = AppStyle.Font.medium(20)
        label.textAlignment = .center
        return label
    }()

    private var courseChangeObserver: Any?
    private var appActiveObserver: Any?
    private var shouldUpdateOnAppear = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        configureTabBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureTable()
        reloadCoursesFromStart(showIndicator: true)
        subscribeToChangesNotifications()
        localizeUI()
    }

    deinit {
        unsubscribeFromChangesNotifications()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        fitTableFooterViewToContentSize()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if self.shouldUpdateOnAppear {
            self.shouldUpdateOnAppear = false
//            self.reloadCourses(type: self.selectedCourseType,
//                               state: self.pagingState,
//                               shouldShowIndicator: false,
//                               completion: nil)
        }
        if let courseId = self.selectedCourseId {
            reloadCourse(courseId: courseId)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCourseInfoViewController" {
            if let destinationVC = segue.destination as? CourseInfoViewController,
                let course = sender as? Course {
                destinationVC.setup(withCourse: course)
            }
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "toCourseInfoViewController" {
            return sender is Course
        }
        return true
    }

    override func localizeUI() {
        super.localizeUI()

        setupNavigationBar()
        self.tableView.reloadData()
    }

    override func openUserProfile() {
        self.performSegue(withIdentifier: "toProfile", sender: nil)
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        let barView = BarActionView()
        barView.setupBarItem(withActions: [.settings])
        barView.onPressSettings = { [weak self] in
            self?.showPreferences()
        }
        let barItem = UIBarButtonItem(customView: barView)
        self.navigationItem.rightBarButtonItems = [barItem]
    }

    // MARK: - Actions
    @objc private func refreshOptions(sender: UIRefreshControl) {
        reloadCoursesFromStart(showIndicator: false, completion: {
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

    private func setupNavigationBar() {
        self.navigationItem.titleView = self.titleCenterLabel
        var titleText: String?
        switch self.selectedCourseType {
        case .recommended:
            titleText = Localization.string("education.group_recommended")
        case .mine:
            titleText = Localization.string("education.group_my")
        case .market:
            titleText = Localization.string("education.group_library")
        }
        self.titleCenterLabel.text = titleText
        self.titleCenterLabel.frame.size = self.titleCenterLabel.approximateSize()
        self.title = nil
    }

    private func configureTable() {
        [CourseTableViewCell.self,
         LoadingTableViewCell.self].forEach { [unowned self] (type) in
            type.registerNib(at: self.tableView)
        }

        self.tableView.separatorInset = AppStyle.Table.separatorInsets
        self.tableView.backgroundColor = AppStyle.Color.backgroundSecondary
        setupRefreshControl()
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

    private func reloadCourse(courseId: String) {
        CoursesService.loadCourse(
            courseId: courseId,
            success: { (course) in
                guard let index = self.courses.firstIndex(where: { (item) -> Bool in
                    return item.identifier == course.identifier
                }) else {
                    return
                }

                self.courses[index] = course
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .none)
        },
            failure: { _ in })
    }

    private func reloadCoursesFromStart(showIndicator: Bool,
                                        completion: (() -> Void)? = nil) {
        guard self.isViewLoaded else { return }
        guard !self.pagingState.isLoading else {
            completion?()
            return
        }

        print("~~~~~~~~reloadCoursesFromStart")
        self.pagingState = PagingState()
        self.pagingState.isLoading = true

        let perPage = self.pagingState.perPage
        let pageNumber = self.pagingState.pageNumber
        loadCourses(type: self.selectedCourseType,
                    state: self.pagingState,
                    shouldShowIndicator: showIndicator,
                    completion: { [weak self] (courses) in
                        guard let courses = courses else {
                            completion?()
                            return
                        }

                        self?.pagingState.pageNumber = pageNumber + 1
                        self?.pagingState.isLoadedLastPage = courses.count < perPage
                        self?.pagingState.isLoading = false


                        self?.courses = courses
                        self?.tableView.reloadData()

                        completion?()
        })
    }

    private func loadNextPage() {
        guard self.isViewLoaded else { return }
        guard !self.pagingState.isLoadedLastPage,
            !self.pagingState.isLoading else {
                return
        }

        print("~~~~~~~~loadNextPage(\(self.pagingState.pageNumber + 1))")

        self.pagingState.isLoading = true
        self.pagingState.isLoadedLastPage = courses.isEmpty

        let perPage = self.pagingState.perPage
        let pageNumber = self.pagingState.pageNumber
        loadCourses(type: self.selectedCourseType,
                    state: self.pagingState,
                    shouldShowIndicator: false,
                    completion: { [weak self] (courses) in
                        guard let courses = courses else { return }

                        self?.pagingState.pageNumber = pageNumber + 1
                        self?.pagingState.isLoadedLastPage = courses.count < perPage
                        self?.pagingState.isLoading = false

                        self?.courses.append(contentsOf: courses)
                        self?.tableView.reloadData()

        })
    }

    private func loadCourses(type: CourseGroupType,
                             state: PagingState,
                             shouldShowIndicator: Bool,
                             completion: (([Course]?) -> Void)?) {
        let pageIndex = state.pageNumber
        let successHandler: ((CoursesListPage) -> Void) = { [weak self] (list) in
            if shouldShowIndicator {
                self?.hideProgressIndicator()
            }
            if let stats = list.stats {
                CommonInfoRepo.shared.updateCommonStats(stats)
            }
            completion?(list.courses)
        }
        let failureHandler: ((NetworkError) -> Void) = { [weak self] (error) in
            if shouldShowIndicator {
                self?.hideProgressIndicator()
            }
            let onRetry: (() -> Void) = { [weak self] in
                self?.loadCourses(type: type,
                                  state: state,
                                  shouldShowIndicator: shouldShowIndicator,
                                  completion: completion)
            }
            self?.showError(error, onRetry: onRetry)
            completion?(nil)
        }

        if shouldShowIndicator {
            showProgressIndicator()
        }
        switch type {
        case .recommended:
            CoursesService.loadRecommendedCourses(page: pageIndex,
                                                  perPage: state.perPage,
                                                  success: successHandler,
                                                  failure: failureHandler)
        case .mine:
            CoursesService.loadMineCourses(page: pageIndex,
                                           perPage: state.perPage,
                                           success: successHandler,
                                           failure: failureHandler)
        case .market:
            CoursesService.loadMarketCourses(page: pageIndex,
                                             perPage: state.perPage,
                                             success: successHandler,
                                             failure: failureHandler)
        }
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
        self.selectedCourseId = course.identifier
        self.performSegue(withIdentifier: "toCourseInfoViewController", sender: course)
    }

    private func openMarketCourse(_ course: Course) {
        guard let courseId = course.identifier else {
            showErrorMessage(forError: .insufficientRequestData)
            return
        }

        showProgressIndicator()
        CoursesService.loadMarketCourse(courseId: courseId,
                                        success: { (marketCourse) in
                                            self.hideProgressIndicator()
                                            marketCourse.isMarketCourse = true
                                            self.showCourse(marketCourse)
        },
                                        failure: { (error) in
                                            let onRetry: (() -> Void) = { [weak self] in
                                                self?.openMarketCourse(course)
                                            }
                                            self.hideProgressIndicator()
                                            self.showError(error, onRetry: onRetry)
        })
    }

    private func showPreferences() {
        let actionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        let newTitle = Localization.string("prefs.new")
        actionSheet.addAction(UIAlertAction(title: newTitle,
                                            style: .default,
                                            color: AppStyle.Color.textMain,
                                            handler: { _ in }))
        let favoritesTitle = Localization.string("prefs.favorites")
        actionSheet.addAction(UIAlertAction(title: favoritesTitle,
                                            style: .default,
                                            color: AppStyle.Color.textMain,
                                            handler: { _ in }))
        let expiringTitle = Localization.string("prefs.expiring")
        actionSheet.addAction(UIAlertAction(title: expiringTitle,
                                            style: .default,
                                            color: AppStyle.Color.textMain,
                                            handler: { _ in }))
        let startedTitle = Localization.string("prefs.started")
        actionSheet.addAction(UIAlertAction(title: startedTitle,
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

    private func fitTableFooterViewToContentSize() {
        // Dynamic sizing for the header view
        if let footerView = tableView.tableFooterView {
            let height = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var footerFrame = footerView.frame

            // If we don't have this check, viewDidLayoutSubviews() will get
            // repeatedly, causing the app to hang.
            if height != footerFrame.size.height {
                footerFrame.size.height = height
                footerView.frame = footerFrame
                tableView.tableFooterView = footerView
            }
        }
    }
}

extension CoursesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showCourse(self.courses[indexPath.row])
    }
}

extension CoursesListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.pagingState.isLoadedLastPage ? 1 : 2
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? self.courses.count : 1
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
        if indexPath.section == 0 {
            return createCourseCell(tableView: tableView,
                                    indexPath: indexPath,
                                    course: self.courses[indexPath.row])
        } else {
            return createLoadingCell(tableView: tableView,
                                     indexPath: indexPath)
        }
    }

    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        if cell is LoadingTableViewCell {
            loadNextPage()
        }
    }

    // MARK: - Private
    private func createCourseCell(tableView: UITableView,
                                  indexPath: IndexPath,
                                  course: Course?) -> CourseTableViewCell {
        let cell: CourseTableViewCell = tableView.dequeCell(at: indexPath)
        TableCellStyle.apply(to: cell, course: course)

        //required title label volume is 3 lines
        cell.titleLabel.numberOfLines = 3

        return cell
    }

    private func createLoadingCell(tableView: UITableView,
                                   indexPath: IndexPath) -> LoadingTableViewCell {
        let cell: LoadingTableViewCell = tableView.dequeCell(at: indexPath)
        cell.activityIndicator.startAnimating()
        return cell
    }
}

extension CoursesListViewController: NotificationHandlerProtocol {
    func handlePushNotification() {
        self.shouldUpdateOnAppear = true
    }
}

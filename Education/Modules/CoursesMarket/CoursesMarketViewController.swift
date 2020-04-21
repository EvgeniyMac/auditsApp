//
//  CoursesMarketViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 26/05/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class CoursesMarketViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topBarUnderView: UIView!

    private var courses = [Course]()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        configureTabBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureTabBar()
        configureTable()
        localizeUI()

        loadMarketCourses()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.rightBarButtonItems?
            .forEach({ (item) in
                if let item = item.customView as? BarActionView {
                    item.reloadBarItem(withAction: .profile)
                }
            })
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
        let barItem = UIBarButtonItem(customView: barView)
        self.navigationItem.rightBarButtonItems = [barItem]
    }

    // MARK: - Actions
    @objc private func refreshOptions(sender: UIRefreshControl) {
        let handler = {
            sender.endRefreshing()
        }
        updateMarketCoursesList(completion: handler)
    }

    // MARK: - Private
    private func configureUI() {
        self.view.backgroundColor = AppStyle.Color.backgroundSecondary
        self.topBarUnderView.backgroundColor = AppStyle.Color.backgroundMain
    }

    private func configureTabBar() {
        self.tabBarItem.title = Localization.string("courses_market.tab_bar_title")
    }

    private func configureTable() {
        let activeCourseCellName = CourseTableViewCell.reuseIdentifier()
        let activeCourseCellNib = UINib(nibName: activeCourseCellName, bundle: nil)
        self.tableView.register(activeCourseCellNib,
                                forCellReuseIdentifier: activeCourseCellName)

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

    private func loadMarketCourses() {
        showProgressIndicator()
        updateMarketCoursesList { [weak self] in
            self?.hideProgressIndicator()
        }
    }

    private func updateMarketCoursesList(completion: (() -> Void)?) {
        CoursesService.loadMarketCourses(
            success: { data in
                self.courses = data.courses
                self.tableView.reloadData()
                completion?()
        },
            failure: { (error) in
                let onRetry: (() -> Void) = { [weak self] in
                    self?.updateMarketCoursesList(completion: completion)
                }
                self.showError(error, onRetry: onRetry)
                completion?()
        })
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

    private func showCourse(_ course: Course) {
        self.performSegue(withIdentifier: "toCourseInfoViewController", sender: course)
    }
}

extension CoursesMarketViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openMarketCourse(self.courses[indexPath.row])
    }
}

extension CoursesMarketViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.courses.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return createCourseCell(tableView: tableView,
                                indexPath: indexPath,
                                course: self.courses[indexPath.row])
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
}

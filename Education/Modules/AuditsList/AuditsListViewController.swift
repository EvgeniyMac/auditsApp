//
//  AuditsListViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 09/11/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class AuditsListViewController: BaseViewController {

    private struct PagingState {
        var pageNumber = 1
        var isLoading = false
        var isLoadedLastPage = false
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var usersLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    private var auditsList = [Audit]()
    private var pagingState = PagingState()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureAuditsListUI()
        localizeUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // always updating on appear according to requirement(#13229)
        loadData(reload: true, showIndicator: self.auditsList.isEmpty)
    }

    override func localizeUI() {
        super.localizeUI()

        let titleText = Localization.string("audit.navigation_bar_title")
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
        barView.onPressSettings = { }
        let barItem = UIBarButtonItem(customView: barView)
        self.navigationItem.rightBarButtonItems = [barItem]
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toAuditItemViewController":
            if let destinationVC = segue.destination as? AuditDetailsViewController,
                let audit = sender as? Audit {
                destinationVC.configureWithAudit(audit)
            }
        default:
            break
        }
    }

    // MARK: - Actions
    @objc private func refreshList(sender: UIRefreshControl) {
        loadData(reload: true, showIndicator: false, completion: {
            sender.endRefreshing()
        })
    }

    // MARK: - Private
    private func configureTabBar() {
        self.tabBarItem.title = Localization.string("audit.tab_bar_title")
    }

    private func configureAuditsListUI() {
        [AuditTableViewCell.self,
         LoadingTableViewCell.self].forEach { [unowned self] (type) in
            type.registerNib(at: self.tableView)
        }

        self.tableView.backgroundColor = AppStyle.Color.backgroundMain
        setupRefreshControl()

        [self.dateLabel, self.cityLabel, self.usersLabel, self.statusLabel]
            .forEach { (label) in
                label?.font = AppStyle.Font.regular(14)
                label?.textColor = AppStyle.Color.textSelected.withAlphaComponent(0.87)
        }
        self.dateLabel.text = Localization.string("audits_list.date.default")
        self.cityLabel.text = Localization.string("audits_list.city.default")
        self.usersLabel.text = Localization.string("audits_list.users.default")
        self.statusLabel.text = Localization.string("audits_list.status.default")
    }

    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = AppStyle.Color.main
        refreshControl.addTarget(self,
                                 action: #selector(refreshList(sender:)),
                                 for: .valueChanged)
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControl
        } else {
            self.tableView.addSubview(refreshControl)
        }
    }

    private func loadData(reload: Bool,
                          showIndicator: Bool,
                          completion: (() -> Void)? = nil) {
        guard (reload || !self.pagingState.isLoadedLastPage),
            !self.pagingState.isLoading else {
                completion?()
                return
        }

        self.pagingState.isLoading = true

        if reload {
            self.pagingState.pageNumber = 1
        } else {
            self.pagingState.pageNumber += 1
        }

        AuditService.getAudits(
            page: self.pagingState.pageNumber,
            filter: AuditFilter(),
            success: { (data) in
                self.pagingState.isLoadedLastPage = data.list?.isEmpty ?? true
                self.pagingState.isLoading = false

                if reload {
                    self.auditsList.removeAll()
                }
                self.auditsList.append(contentsOf: data.list ?? [])
                self.tableView.reloadData()

                completion?()
            },
            failure: { (error) in
                self.showError(error, onRetry: nil)
                completion?()
            })
    }
}

extension AuditsListViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.pagingState.isLoadedLastPage ? 1 : 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.auditsList.count
        case 1:
            return 1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let audit = self.auditsList[indexPath.row]
            let cell = tableView.dequeCell(at: indexPath) as AuditTableViewCell
            cell.setup(with: audit)
            return cell
        } else {
            return createLoadingCell(tableView: tableView,
                                     indexPath: indexPath)
        }
    }

    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        if cell is LoadingTableViewCell {
            loadData(reload: false, showIndicator: false)
        }
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.row < self.auditsList.count {
            openAudit(self.auditsList[indexPath.row])
        }
    }

    // MARK: - Private
    private func createLoadingCell(tableView: UITableView,
                                   indexPath: IndexPath) -> LoadingTableViewCell {
        let cell: LoadingTableViewCell = tableView.dequeCell(at: indexPath)
       cell.activityIndicator.startAnimating()
        return cell
    }

    private func openAudit(_ audit: Audit) {
        self.performSegue(withIdentifier: "toAuditItemViewController", sender: audit)
    }
}

extension AuditsListViewController: NotificationHandlerProtocol {
    func handlePushNotification() { }
}

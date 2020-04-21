//
//  NewsListViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 19.12.2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class NewsListViewController: BaseViewController {

    private struct PagingState {
        var pageNumber = 1
        var isLoading = false
        var isLoadedLastPage = false
    }

    @IBOutlet weak var tableView: UITableView!

    private var newsList = [NewsItem]()
    private var pagingState = PagingState()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNewsListUI()
        localizeUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // always updating on appear according to requirement(#13229)
        loadData(reload: true, showIndicator: self.newsList.isEmpty)

        self.navigationItem.rightBarButtonItems?
            .forEach({ (item) in
                if let item = item.customView as? BarActionView {
                    item.reloadBarItem(withAction: .profile)
                }
            })
    }

    override func localizeUI() {
        super.localizeUI()

        self.title = Localization.string("news.navigation_bar_title")

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
        case "toNewsItemViewController":
            if let destinationVC = segue.destination as? NewsItemViewController,
                let newsItem = sender as? NewsItem {
                destinationVC.newsItem = newsItem
            }
        default:
            break
        }
    }

    // MARK: - Actions
    @objc private func refreshOptions(sender: UIRefreshControl) {
        loadData(reload: true, showIndicator: false, completion: {
            sender.endRefreshing()
        })
    }

    // MARK: - Private
    private func configureNewsListUI() {
        [NewsItemFullTableViewCell.self,
         NewsItemHalfTableViewCell.self,
         NewsItemQuarterTableViewCell.self,
         LoadingTableViewCell.self].forEach { [unowned self] (type) in
            type.registerNib(at: self.tableView)
        }

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

        NewsService.getArticles(
            page: self.pagingState.pageNumber,
            success: { (data) in
                self.pagingState.isLoadedLastPage = data.list?.isEmpty ?? true
                self.pagingState.isLoading = false

                if reload {
                    self.newsList.removeAll()
                }
                self.newsList.append(contentsOf: data.list ?? [])
                self.tableView.reloadData()

                completion?()
            },
            failure: { (error) in
                self.showError(error, onRetry: nil)
                completion?()
            })
    }
}

extension NewsListViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        if self.pagingState.isLoadedLastPage {
            return self.newsList.count
        } else {
            return self.newsList.count + 1
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < self.newsList.count {
            let newsItem = self.newsList[indexPath.section]
            let cell = createNewsCell(tableView: tableView,
                                      indexPath: indexPath,
                                      newsItem: newsItem)
            cell.setup(with: newsItem)
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

        if indexPath.section < self.newsList.count {
            openNewsItem(self.newsList[indexPath.section])
        }
    }

    // MARK: - Private
    private func createNewsCell(tableView: UITableView,
                                indexPath: IndexPath,
                                newsItem: NewsItem) -> NewsItemTableViewCellProtocol {
        switch newsItem.setting?.displayType {
        case .full:
            return tableView.dequeCell(at: indexPath) as NewsItemFullTableViewCell
        case .half:
            return tableView.dequeCell(at: indexPath) as NewsItemHalfTableViewCell
        case .quarter:
            return tableView.dequeCell(at: indexPath) as NewsItemQuarterTableViewCell
        default:
            // displaying a Full cell type by default
            return tableView.dequeCell(at: indexPath) as NewsItemFullTableViewCell
        }
    }

    private func createLoadingCell(tableView: UITableView,
                                   indexPath: IndexPath) -> LoadingTableViewCell {
        let cell: LoadingTableViewCell = tableView.dequeCell(at: indexPath)
        cell.activityIndicator.startAnimating()
        return cell
    }

    private func openNewsItem(_ newsItem: NewsItem) {
        self.performSegue(withIdentifier: "toNewsItemViewController", sender: newsItem)
    }
}

extension NewsListViewController: NotificationHandlerProtocol {
    func handlePushNotification() { }
}

//
//  CommunicationViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 24.12.2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class CommunicationViewController: BaseViewController {
    struct HelpChatItem {
        let type: HelpChatType

        var title: String {
            switch type {
            case .support:
                return Localization.string("help_chat.support.title")
            case .idea:
                return Localization.string("help_chat.idea.title")
            case .claim:
                return Localization.string("help_chat.claim.title")
            case .bossHelp:
                return Localization.string("help_chat.boss_help.title")
            }
        }

        var logoImage: UIImage? {

            switch type {
            case .support:
                return UIImage(named: "help_chat.support")
            case .idea:
                return UIImage(named: "help_chat.idea")
            case .claim:
                return UIImage(named: "help_chat.claim")
            case .bossHelp:
                return UIImage(named: "help_chat.boss_help")
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet var headerView: UIView!
    @IBOutlet weak var headerAllButton: UIButton!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var headerSubtitleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    private var newsList = [NewsItem]()
    private var newsTotalCount = Int.zero
    private var isNewsListLoaded = false
    private let helpChats = [HelpChatItem(type: .support),
                             HelpChatItem(type: .idea),
                             HelpChatItem(type: .bossHelp)]
    private let topPageIndex: Int = 1
    private var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableHeaderView = self.headerView

        configureCommunicationTable()
        configureCommunicationHeader()
        reloadTopNews(showIndicator: true)
        localizeUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // always updating on appear according to requirement(#13229)
        reloadTopNews(showIndicator: false)

        self.navigationItem.rightBarButtonItems?
            .forEach({ (item) in
                if let item = item.customView as? BarActionView {
                    item.reloadBarItem(withAction: .profile)
                }
            })
    }

    override func localizeUI() {
        super.localizeUI()

        let titleText = Localization.string("communication.navigation_bar_title")
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
        case "toNewsItemViewController":
            if let destinationVC = segue.destination as? NewsItemViewController,
                let newsItem = sender as? NewsItem {
                destinationVC.newsItem = newsItem
            }
        case "toHelpChatViewController":
            if let navVC = segue.destination as? UINavigationController,
                let chatVC = navVC.viewControllers.first as? HelpChatViewController,
                let helpChat = sender as? HelpChat {
                chatVC.helpChat = helpChat
            }
        default:
            break
        }
    }

    // MARK: - Actions
    @objc private func refreshOptions(sender: UIRefreshControl) {
        reloadTopNews(showIndicator: false, completion: {
            sender.endRefreshing()
        })
    }

    // MARK: - Private
    private func configureCommunicationTable() {
        [NewsItemFullTableViewCell.self,
         NewsItemHalfTableViewCell.self,
         NewsItemQuarterTableViewCell.self,
         DoubleLabelTableViewCell.self,
         HeaderTableViewCell.self].forEach { [unowned self] (type) in
            type.registerNib(at: self.tableView)
        }

        self.tableView.backgroundColor = AppStyle.Color.backgroundMain
        setupRefreshControl()

    }

    private func configureCommunicationHeader() {
        let chatCellId = HelpChatCollectionViewCell.viewReuseIdentifier()
        let cellNib = UINib(nibName: chatCellId, bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: chatCellId)
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: 105, height: 90)
            flowLayout.minimumInteritemSpacing = 10
            flowLayout.sectionInset = UIEdgeInsets(all: 20)
        }

        self.headerView.backgroundColor = AppStyle.Color.custom(hex: 0xF2C48C)
        self.headerTitleLabel.textColor = AppStyle.Color.textMain
        self.headerTitleLabel.font = AppStyle.Font.medium(20)
        self.headerTitleLabel.text = Localization.string("communication.header.title")
        self.headerSubtitleLabel.textColor = AppStyle.Color.textMainBrightened
        self.headerSubtitleLabel.font = AppStyle.Font.regular(16)
        self.headerSubtitleLabel.text = Localization.string("communication.header.subtitle")

        self.headerAllButton.setTitleColor(AppStyle.Color.green, for: .normal)
        let headerActionTitle = Localization.string("communication.header.action")
        self.headerAllButton.setTitle(headerActionTitle, for: .normal)
        self.headerAllButton.titleLabel?.font = AppStyle.Font.regular(16)

        //TODO: uncomment later
        self.headerAllButton.isHidden = true
    }

    private func configureTabBar() {
        self.tabBarItem.title = Localization.string("chat.tab_bar_title")
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

    func reloadTopNews(showIndicator: Bool,
                       completion: (() -> Void)? = nil) {
        self.isLoading = true
        NewsService.getArticles(page: self.topPageIndex,
                                success: { (data) in
                                    self.isLoading = false

                                    self.newsTotalCount = data.totalCount ?? Int.zero
                                    self.newsList.removeAll()
                                    self.newsList.append(contentsOf: data.list ?? [])
                                    self.isNewsListLoaded = true
                                    self.tableView.reloadData()

                                    completion?()
        },
                                failure: { (error) in
                                    self.showError(error, onRetry: nil)
                                    completion?()
        })
    }
}

extension CommunicationViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.newsList.isEmpty {
            return self.isNewsListLoaded ? 1 : 0
        } else {
            return self.newsList.count
        }
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if self.newsList.isEmpty {
            return 1
        } else {
            return (section == 0) ? 2 : 1
        }
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
        if indexPath.section == .zero,
            indexPath.row == .zero {
            if self.newsList.isEmpty {
                return createNoNewsCell(tableView: tableView, indexPath: indexPath)
            } else {
                return createHeaderCell(tableView: tableView, indexPath: indexPath)
            }
        } else {
            let newsItem = self.newsList[indexPath.section]
            let cell = createNewsCell(tableView: tableView,
                                      indexPath: indexPath,
                                      newsItem: newsItem)
            cell.setup(with: newsItem)
            return cell
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

    private func createHeaderCell(tableView: UITableView,
                                  indexPath: IndexPath) -> HeaderTableViewCell {
        let cell: HeaderTableViewCell = tableView.dequeCell(at: indexPath)

        let allTitle = Localization.string("communication.news_action")
        var actionTitle: String
        if self.newsTotalCount > 0 {
            actionTitle = "\(allTitle) \(self.newsTotalCount)"
        } else {
            actionTitle = allTitle
        }

        cell.setupWith(title: Localization.string("communication.news_title"),
                       actionTitle: actionTitle,
                       action: { [weak self] in
                        self?.showAllNews()
        })

        // clippting top for HeaderTableViewCell in the first section
        cell.isClippedTop = (indexPath.section == 0)

        cell.selectionStyle = .none

        return cell
    }

    private func createNoNewsCell(tableView: UITableView,
                                  indexPath: IndexPath) -> DoubleLabelTableViewCell {
        let cell: DoubleLabelTableViewCell = tableView.dequeCell(at: indexPath)
        cell.titleLabel.text = Localization.string("communication.no_news.title")
        cell.subtitleLabel.text = Localization.string("communication.no_news.subtitle")
        cell.selectionStyle = .none
        return cell
    }

    private func openNewsItem(_ newsItem: NewsItem) {
        self.performSegue(withIdentifier: "toNewsItemViewController", sender: newsItem)
    }

    private func showAllNews() {
        self.performSegue(withIdentifier: "toNewsListViewController", sender: nil)
    }
}

extension CommunicationViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.helpChats.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellId = HelpChatCollectionViewCell.viewReuseIdentifier()
        guard let chatCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellId,
            for: indexPath) as? HelpChatCollectionViewCell else {
                fatalError("Unable to load HelpChatCollectionViewCell")
        }

        let chatType = self.helpChats[indexPath.row]
        chatCell.logoImageView.image = chatType.logoImage
        chatCell.setup(titleText: chatType.title)

        return chatCell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        let helpChat = self.helpChats[indexPath.row]
        shouldOpenHelpChat(type: helpChat.type)
    }

    private func shouldOpenHelpChat(type: HelpChatType) {
        showProgressIndicator()
        ChatsService.requestHelpChat(type: type,
                                     success: { (chat) in
                                        self.hideProgressIndicator()
                                        self.openHelpChat(chat)
        },
                                     failure: { (error) in
                                        self.hideProgressIndicator()
                                        self.showError(error, onRetry: nil)
        })
    }

    private func openHelpChat(_ chat: HelpChat) {
        self.performSegue(withIdentifier: "toHelpChatViewController", sender: chat)
    }
}

extension CommunicationViewController: NotificationHandlerProtocol {
    func handlePushNotification() { }
}

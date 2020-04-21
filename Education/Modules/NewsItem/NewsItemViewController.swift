//
//  NewsItemViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 21.12.2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit
import WebKit

class NewsItemViewController: BaseViewController {

    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var categoryContainer: UIView!
    @IBOutlet weak var categoryLabel: MarginLabel!
    @IBOutlet weak var titleContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorContainer: UIView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var contentContainerHeightConstraint: NSLayoutConstraint!

    public var newsItem: NewsItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNewsItemUI()
        setupNewsItem(self.newsItem)
        if let newsItemId = self.newsItem?.identifier {
            updateNewsItem(itemId: newsItemId)
        }
        localizeUI()
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

    override func localizeUI() {
        super.localizeUI()

        self.title = Localization.string("news.navigation_bar_title")
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

    // MARK: - Private
    private func configureNewsItemUI() {
        self.stackView.spacing = 10

        self.categoryLabel.numberOfLines = Int.zero
        self.categoryLabel.textColor = AppStyle.Color.white
        self.categoryLabel.font = AppStyle.Font.regular(12)
        self.categoryLabel.backgroundColor = AppStyle.Color.purple
        self.categoryLabel.insets = UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 6)
        self.categoryLabel.layer.cornerRadius = AppStyle.CornerRadius.label
        self.categoryLabel.layer.masksToBounds = true

        self.titleLabel.numberOfLines = Int.zero
        self.titleLabel.textColor = AppStyle.Color.textSelected
        self.titleLabel.font = AppStyle.Font.medium(18)

        self.authorLabel.numberOfLines = Int.zero
        self.authorLabel.textColor = AppStyle.Color.textMainBrightened
        self.authorLabel.font = AppStyle.Font.regular(12)
    }

    private func setupNewsItem(_ item: NewsItem?) {
        guard self.isViewLoaded else { return }

        self.categoryLabel.text = item?.categoryName
        self.categoryContainer.isHidden = item?.categoryName?.isEmpty ?? true

        self.titleLabel.text = item?.name
        self.titleContainer.isHidden = item?.name?.isEmpty ?? true

        if let html = item?.content,
            !html.isEmpty {
                let webView = createWebView(using: html)
                contentContainer.addSubview(webView)
                let constraints = contentContainer
                    .createContiguousConstraints(toView: webView)
                contentContainer.addConstraints(constraints)
        }

        let dateString = item?.dateCreated?.dateTimeString(dateFormat: "dd MMM HH:mm",
                                                           timeFormat: nil,
                                                           locale: Locale.current)
        let authorText = [item?.authorName, dateString]
            .compactMap({ $0 }).joined(separator: " \u{2022} ")
        self.authorLabel.text = authorText
        self.authorContainer.isHidden = authorText.isEmpty
    }

    private func updateNewsItem(itemId: String) {
        showProgressIndicator()
        NewsService.getArticle(
            articleId: itemId,
            success: { (item) in
                self.hideProgressIndicator()
                self.newsItem = item
                self.setupNewsItem(item)
            },
            failure: { (error) in
                var onDismiss: (() -> Void)?
                switch error {
                case .itemNotFound:
                    onDismiss = { [weak self] in
                        self?.closeModulesStack()
                    }
                default:
                    onDismiss = nil
                }

                self.hideProgressIndicator()
                self.showError(error, onRetry: nil, onDismiss: onDismiss)
            })
    }

    // MARK: - Private - WKWebView
    private func createWebView(using html: String) -> WKWebView {
        let webView = WKWebView(frame: .zero,
                                configuration: webViewConfiguration())
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.loadHTMLString(html, baseURL: nil)

        // disabling scroll using inner ScrollView to perform scrolling using outer ScrollView
        webView.scrollView.isScrollEnabled = false
        return webView
    }

    private func webViewConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController()
        return configuration
    }

    private func userContentController() -> WKUserContentController {
        let controller = WKUserContentController()
        controller.addUserScript(viewPortScript())
        return controller
    }

    private func viewPortScript() -> WKUserScript {
        let viewPortScript = """
            var meta = document.createElement('meta');
            meta.setAttribute('name', 'viewport');
            meta.setAttribute('content', 'width=device-width');
            meta.setAttribute('initial-scale', '1.0');
            meta.setAttribute('maximum-scale', '1.0');
            meta.setAttribute('minimum-scale', '1.0');
            meta.setAttribute('user-scalable', 'no');
            document.getElementsByTagName('head')[0].appendChild(meta);
        """
        return WKUserScript(source: viewPortScript,
                            injectionTime: .atDocumentEnd,
                            forMainFrameOnly: true)
    }
}

extension NewsItemViewController: WKNavigationDelegate {
    private func update(webView: WKWebView, for height: CGFloat) {
        self.contentContainerHeightConstraint.constant = height
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.readyState", completionHandler: { [weak webView] (complete, error) in
            guard let webView = webView,
                complete != nil else {
                    return
            }

            webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { [weak webView] (height, error) in
                guard let webView = webView,
                    let height = height as? CGFloat else {
                        return
                }
                self.update(webView: webView, for: height)
            })
        })
    }
}

extension NewsItemViewController: NotificationHandlerProtocol {
    func handlePushNotification() { }
}

//
//  HelpChatViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 26.12.2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit
import WebKit

class HelpChatViewController: UIViewController {

    public var helpChat: HelpChat?

    @IBOutlet private weak var containerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let html = self.helpChat?.content,
            !html.isEmpty {
            let webView = createWebView(using: html)
            self.containerView.addSubview(webView)
            let constraints = self.containerView
                .createContiguousConstraints(toView: webView)
            self.containerView.addConstraints(constraints)
        }

        let closeTitle = Localization.string("common.action.close")
        let closeItem = UIBarButtonItem(title: closeTitle,
                                        style: .done,
                                        target: self,
                                        action: #selector(closeDialog))
        closeItem.setTitleTextAttributes([.foregroundColor : AppStyle.Color.textMain],
                                         for: .normal)
        self.navigationItem.leftBarButtonItem = closeItem
    }

    // MARK: - Actions
    @objc private func closeDialog() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    // MARK: - Private
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

extension HelpChatViewController: WKNavigationDelegate {
}

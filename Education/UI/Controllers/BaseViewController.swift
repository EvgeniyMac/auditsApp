//
//  BaseViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 22/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    private var languageObserver: Any?
    private var headerTitleLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: String(),
                                                                style: .plain,
                                                                target: nil,
                                                                action: nil)
        
        configureNavigationBar()

        subscribeToLanguageNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if #available(iOS 11.0, *) {
            self.tabBarController?.tabBar.isHidden = shouldHideTabBar()
        } else {
            if shouldHideTabBar() {
                self.tabBarController?.tabBar.isHidden = true
                self.edgesForExtendedLayout = .bottom
            } else {
                self.tabBarController?.tabBar.isHidden = false
                self.edgesForExtendedLayout = []
            }
        }
    }

    deinit {
        unsubscribeFromLanguageNotifications()
        print("DEINIT: \(String(describing: self))")
    }

    // MARK: - Public
    func setupHeaderTitle(text: String?) {
        if #available(iOS 11, *) {
            self.headerTitleLabel?.text = text
            self.title = nil
        } else if let labelSize = self.headerTitleLabel?.approximateSize() {
            self.headerTitleLabel?.text = text
            self.headerTitleLabel?.frame.size = labelSize
            self.title = nil
        } else {
            self.headerTitleLabel?.text = nil
            self.title = text
        }
    }

    func setupContentInsets(for scrollView: UIScrollView) {
        if #available(iOS 11, *) {
        } else {
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            let navBarHeight = self.navigationController?.navigationBar.frame.height
            let topInset = statusBarHeight + (navBarHeight ?? 0)
            scrollView.contentInset.top = topInset

            let bottomInset = self.tabBarController?.tabBar.frame.height
            scrollView.contentInset.bottom = bottomInset ?? 0
        }
    }

    // MARK: - Open methods
    open func localizeUI() {
    }

    open func openUserProfile() {
    }

    open func shouldHideTabBar() -> Bool {
        return false
    }

    open func configureNavigationBar() {
        if let navController = self.navigationController as? TabNavigationController,
            navController.viewControllers.first === self {
            configureNavigationBar(title: self.title)
        }

        if self.navigationController?.viewControllers.first !== self {
            configureBackButton()
        }
    }

    open func shouldMoveBack() {
        self.navigationController?.popViewController(animated: true)
    }

    open func configureBackButton() {
        //configuring back button
        let finishItem = UIBarButtonItem(image: UIImage(named: "arrow_back"),
                                         style: .done,
                                         target: self,
                                         action: #selector(didPressBackButton(sender:)))
        self.navigationItem.leftBarButtonItem = finishItem
        self.navigationItem.hidesBackButton = true
    }

    // MARK: - Actions
    @objc private func didPressProfileButton(sender: Any) {
        openUserProfile()
    }

    @objc private func didPressBackButton(sender: Any) {
        shouldMoveBack()
    }

    // MARK: - Private
    private func isTabBarVisible() -> Bool {
        guard let controller = self.tabBarController else {
            return false
        }
        return controller.tabBar.frame.origin.y < self.view.frame.maxY
    }

    private func configureNavigationBar(title: String?) {
        let label = UILabel(frame: .zero)
        label.font = AppStyle.Font.medium(28)
        label.textColor = AppStyle.Color.textMain
        label.text = title
        self.headerTitleLabel = label

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)
    }

    // MARK: - Notifications
    private func subscribeToLanguageNotifications() {
        self.languageObserver = NotificationCenter.default
            .addObserver(forName: .DidChangeLanguage,
                         object: nil,
                         queue: nil) { [unowned self] _ in
                            self.localizeUI()
        }
    }

    private func unsubscribeFromLanguageNotifications() {
        if let observer = languageObserver {
            languageObserver = nil
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

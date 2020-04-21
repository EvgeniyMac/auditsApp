//
//  MainNavigationController.swift
//  Education
//
//  Created by Andrey Medvedev on 19/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {

    private var authorizeObserver: Any?
    private var unauthorizeObserver: Any?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        subscribeToNotifications()
        if UserManager.isAuthenticated() {
            setupTabsScreen()
        } else {
            setupSplashScreen()
        }
    }

    deinit {
        unsubscribeFromNotifications()
    }

    // MARK: - Private
    private func configureUI() {
        self.navigationBar.isHidden = true
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.tintColor = AppStyle.Color.navigationBarTint
        self.navigationBar.barTintColor = AppStyle.Color.navigationBarBackground
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: AppStyle.Font.medium(16)]

        if #available(iOS 11.0, *) {
            // making navigation bar transparent
            self.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationBar.isTranslucent = true
        } else {
            let bgImage = UIImage(color: AppStyle.Color.white)
            self.navigationBar.setBackgroundImage(bgImage, for: .default)
            self.navigationBar.isTranslucent = false
        }

        if #available(iOS 11.0, *) {
            // setting large titles attributes
            let attributes = AppStyle.Text.largeTitleDefault
            self.navigationBar.largeTitleTextAttributes = attributes
        }
    }

    private func setupSplashScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SplashViewControllerID")
        self.viewControllers = [vc]
    }

    private func setupTabsScreen() {
        let storyboard = UIStoryboard(name: "Tabs", bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() else {
            fatalError("Tabs storyboard has no initial view controller")
        }
        self.viewControllers = [vc]
    }

    // MARK: - Notifications
    private func subscribeToNotifications() {
        self.authorizeObserver = NotificationCenter.default
            .addObserver(forName: .DidAuthorize,
                         object: nil,
                         queue: nil) { [unowned self] _ in
                            self.sendUserTimeZone()
                            self.setupTabsScreen()
        }
        self.unauthorizeObserver = NotificationCenter.default
            .addObserver(forName: .DidUnauthorize,
                         object: nil,
                         queue: nil) { [unowned self] _ in
                            self.setupSplashScreen()
        }
    }

    private func unsubscribeFromNotifications() {
        if let observer = authorizeObserver {
            authorizeObserver = nil
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = unauthorizeObserver {
            unauthorizeObserver = nil
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func sendUserTimeZone() {
        // TODO: move this method elsewhere
        let timeZone = TimeZone.current.identifier
        UsersService.sendUserTimeZone(timeZone: timeZone,
                                      success: {},
                                      failure: { _ in })
    }
}

//
//  NavigationManager.swift
//  Education
//
//  Created by Andrey Medvedev on 10/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class NavigationManager {

    static let shared = NavigationManager()

    // should reset after an app restart
    private var shouldShowWalkthrough: Bool = true

    private var authorizeObserver: Any?
    private var unauthorizeObserver: Any?

    init() {
        subscribeToNotifications()
    }

    deinit {
        unsubscribeFromNotifications()
    }

    // MARK: - Public
    public func setup() {
        if UserManager.isAuthenticated() {
            self.shouldShowWalkthrough = false
            setupTabsScreen()
        } else if self.shouldShowWalkthrough {
            self.shouldShowWalkthrough = false
            setupWalkthroughScreen()
        } else {
            setupAuthScreen()
        }
    }

    // MARK: - Private
    private func setupAuthScreen() {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() else {
            fatalError("Auth storyboard has no initial view controller")
        }

        guard let appDelegate = UIApplication.shared.delegate else {
            return
        }
        appDelegate.window??.rootViewController = vc
    }

    private func setupTabsScreen() {
        let storyboard = UIStoryboard(name: "Tabs", bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() else {
            fatalError("Tabs storyboard has no initial view controller")
        }

        guard let appDelegate = UIApplication.shared.delegate else {
            return
        }
        appDelegate.window??.rootViewController = vc
    }

    private func setupWalkthroughScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let screenId = "WalkthroughViewControllerID"
        let vc = storyboard.instantiateViewController(withIdentifier: screenId)

        guard let appDelegate = UIApplication.shared.delegate else {
            return
        }
        appDelegate.window??.rootViewController = vc
    }

    private func sendUserTimeZone() {
        // TODO: move this method elsewhere
        let timeZone = TimeZone.current.identifier
        UsersService.sendUserTimeZone(timeZone: timeZone,
                                      success: {},
                                      failure: { _ in })
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
                            self.setupAuthScreen()
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
}

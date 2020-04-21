//
//  EducationTabBarController.swift
//  Education
//
//  Created by Andrey Medvedev on 26/05/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class EducationTabBarController: UITabBarController {

    private enum Tab: Int {
        case courses = 0
        case audit
        case todo
        case library
        case communication
    }

    private let activeTabs = [Tab.courses,
                              Tab.audit,
                              Tab.library,
                              Tab.communication]
    private let selectedIndexDefault: Int = 0

    private var pushNotificationObserver: Any?
    private var languageObserver: Any?
    private var statsObserver: Any?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self

        configureTabBar()
        subscribeToNotifications()
        localizeUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showInstanceFromPushNotificationIfNeeded()
    }

    deinit {
        unsubscribeFromNotifications()
        print("DEINIT: \(String(describing: self))")
    }

    // MARK: - Private
    private func configureTabBar() {
        self.tabBar.barTintColor = AppStyle.Color.backgroundMain
        if #available(iOS 10.0, *) {
            self.tabBar.unselectedItemTintColor = AppStyle.Color.tintUnselected
        } else {
            // TODO: Fallback on earlier versions
        }

        self.selectedIndex = self.selectedIndexDefault
        let selectedTab = self.activeTabs[self.selectedIndexDefault]
        updateTabBarItem(tab: selectedTab)
    }

    private func localizeUI() {
        self.viewControllers?.forEach({ (vc) in
            if let navController = vc as? UINavigationController {
                if let vc = navController.viewControllers.first as? BaseViewController {
                    vc.localizeUI()
                }
            } else if let vc = vc as? BaseViewController {
                vc.localizeUI()
            }
        })
    }

    private func colorForBarItem(tab: Tab) -> UIColor {
        switch tab {
        case .courses:
            return AppStyle.Color.blue
        case .audit:
            return AppStyle.Color.orange
        case .todo:
            return AppStyle.Color.red
        case .library:
            return AppStyle.Color.green
        case .communication:
            return AppStyle.Color.purple
        }
    }

    private func updateTabBarItem(tab: Tab) {
        self.tabBar.tintColor = colorForBarItem(tab: tab)
    }

    private func setupBadgeValue(_ badgeValue: Int?,
                                 with color: UIColor?,
                                 for tabBarItem: UITabBarItem) {
        var valueString: String?
        if let valueInt = badgeValue {
            valueString = (valueInt > 0) ? String(valueInt) : nil
        }

        tabBarItem.badgeValue = valueString
        if #available(iOS 10.0, *) {
            tabBarItem.badgeColor = color
        }
    }

    private func updateStats() {
        self.viewControllers?.forEach({ (viewController) in
            if let navController = viewController as? UINavigationController,
                navController.viewControllers.first is EducationViewController {
                if let info = CommonInfoRepo.shared.getCommonStats() {
                    setupBadgeValue(info.newAppointmentsCount,
                                    with: AppStyle.Color.red,
                                    for: navController.tabBarItem)
                }
            }
        })
    }

    // MARK: - Notifications
    private func subscribeToNotifications() {
        self.pushNotificationObserver = NotificationCenter.default
            .addObserver(forName: .DidReceivePushNotification,
                         object: nil,
                         queue: nil) { [weak self] _ in
                            self?.showInstanceFromPushNotificationIfNeeded()
        }
        self.languageObserver = NotificationCenter.default
            .addObserver(forName: .DidChangeLanguage,
                         object: nil,
                         queue: nil) { [unowned self] _ in
                            self.localizeUI()
        }
        self.statsObserver = NotificationCenter.default
            .addObserver(forName: .DidUpdateStats,
                         object: nil,
                         queue: nil) { [unowned self] _ in
                            self.updateStats()
        }
    }

    private func unsubscribeFromNotifications() {
        if let observer = self.pushNotificationObserver {
            self.pushNotificationObserver = nil
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = self.languageObserver {
            self.languageObserver = nil
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = self.statsObserver {
            self.statsObserver = nil
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = self.statsObserver {
            self.statsObserver = nil
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func showInstanceFromPushNotificationIfNeeded() {
        let manager = NotificationManager.shared
        guard let dictionary = manager.pendingNotification else { return }
        let notificationData = PushNotificationData(JSON: dictionary)

        manager.pendingNotification = nil
        handlePushNotification(data: notificationData)
    }

    private func handlePushNotification(data: PushNotificationData?) {
        if data?.appointmentId != nil { // Course
            openTab(.courses, with: data)
        } else if data?.articleId != nil { // NewsItem
            openTab(.communication, with: data)
        }
    }

    private func openTab(_ tab: Tab, with data: PushNotificationData?) {
        guard let tabIndex = self.activeTabs.firstIndex(of: tab) else {
            return
        }

        self.selectedIndex = tabIndex
        updateTabBarItem(tab: tab)

        if let navController = self.viewControllers?[tabIndex] as? TabNavigationController {
            DispatchQueue.main.async {
                navController.handlePushNotification(data: data)
            }
        }
    }
}

extension EducationTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
        guard let index = tabBarController.viewControllers?
            .firstIndex(of: viewController) else {
                return
        }

        let tab = self.activeTabs[index]
        updateTabBarItem(tab: tab)
    }
}

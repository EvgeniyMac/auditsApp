//
//  AuthNavigationController.swift
//  Education
//
//  Created by Andrey Medvedev on 17/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class AuthNavigationController: UINavigationController {

    private var authorizeObserver: Any?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        subscribeToNotifications()
    }

    deinit {
        unsubscribeFromNotifications()
    }

    // MARK: - Private
    private func configureUI() {
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

    // MARK: - Notifications
    private func subscribeToNotifications() {
        self.authorizeObserver = NotificationCenter.default.addObserver(forName: Notification.Name.DidAuthorize,
                                                                        object: nil,
                                                                        queue: nil) { [unowned self] _ in
                                                                            self.dismiss(animated: true,
                                                                                         completion: nil)
        }
    }

    private func unsubscribeFromNotifications() {
        if let observer = authorizeObserver {
            authorizeObserver = nil
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

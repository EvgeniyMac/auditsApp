//
//  AuditViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 09/11/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class AuditViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // showing an under construction screen
        showErrorScreen(error: nil, onRetry: nil)

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

        let titleText = Localization.string("audit.navigation_bar_title")
        self.setupHeaderTitle(text: titleText)
        configureTabBar()
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
    private func configureTabBar() {
        self.tabBarItem.title = Localization.string("audit.tab_bar_title")
    }

}

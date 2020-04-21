//
//  ChatViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 09/11/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class ChatViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // showing an under construction screen
        showErrorScreen(error: nil, onRetry: nil)

        localizeUI()
    }

    override func localizeUI() {
        super.localizeUI()

        configureTabBar()
    }

    // MARK: - Private
    private func configureTabBar() {
        self.tabBarItem.title = Localization.string("chat.tab_bar_title")
    }
}

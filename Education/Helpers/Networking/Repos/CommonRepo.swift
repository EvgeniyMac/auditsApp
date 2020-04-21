//
//  CommonRepo.swift
//  Education
//
//  Created by Andrey Medvedev on 05/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

class CommonRepo {

    private var unauthorizeObserver: Any?

    open func clean() {
    }

    // MARK: - Notifications
    private func subscribeToNotifications() {
        self.unauthorizeObserver = NotificationCenter.default
            .addObserver(forName: .DidUnauthorize,
                         object: nil,
                         queue: nil) { [unowned self] _ in
                            self.clean()
        }
    }

    private func unsubscribeFromNotifications() {
        if let observer = unauthorizeObserver {
            unauthorizeObserver = nil
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

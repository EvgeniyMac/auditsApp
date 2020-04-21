//
//  TimeoutHandler.swift
//  Education
//
//  Created by Andrey Medvedev on 29/09/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

class TimeoutHandler {
    let timeout: Timeout
    let updateInterval: TimeInterval
    private let onUpdate: ((TimeInterval) -> Void)?
    private var timer: Timer?

    init(timeout: Timeout,
         updateInterval: TimeInterval = 1,
         onUpdate: ((TimeInterval) -> Void)?) {
        self.timeout = timeout
        self.updateInterval = updateInterval
        self.onUpdate = onUpdate
        self.timer = Timer.scheduledTimer(timeInterval: updateInterval,
                                          target: self,
                                          selector: #selector(updateTimer),
                                          userInfo: nil,
                                          repeats: true)
    }

    // MARK: - Actions
    @objc private func updateTimer() {
        let remainingTime = self.timeout.remainingTime
        self.onUpdate?(remainingTime)
        if remainingTime <= TimeInterval.zero {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
}

struct Timeout {
    let start: Date
    let duration: TimeInterval

    var end: Date {
        return Date(timeInterval: duration, since: start)
    }

    var remainingTime: TimeInterval {
        let currentDate = Date()
        let endDate = self.end
        if currentDate < endDate {
            return endDate.timeIntervalSince(currentDate)
        }
        return .zero
    }

    var isOver: Bool {
        return Date() > end
    }
}

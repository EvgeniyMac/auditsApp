//
//  LessonTimeTracker.swift
//  Education
//
//  Created by Andrey Medvedev on 20/05/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

class LessonTimeTracker {
    enum LessonTimeTrackerState {
        case initial
        case tracking
        case completed
    }

    private var startDate: Date?
    private var endDate: Date?

    var duration: TimeInterval? {
        guard let dateStart = self.startDate,
            let dateEnd = self.endDate,
            dateStart <= dateEnd else {
                return nil
        }
        return dateEnd.timeIntervalSince(dateStart)
    }

    var state: LessonTimeTrackerState {
        if self.startDate == nil {
            return .initial
        } else if self.endDate == nil {
            return .tracking
        } else {
            return .completed
        }
    }

    func start() {
        guard self.state == .initial else {
            print("WARNING: LessonTimeTracker was stopped while not in an initial state")
            return
        }

        self.startDate = Date()
        self.endDate = nil
    }

    func stop() {
        guard self.state == .tracking else {
            print("WARNING: LessonTimeTracker was stopped while not in a tracking state")
            return
        }

        self.endDate = Date()
    }

    func reset() {
        self.startDate = nil
        self.endDate = nil
    }
}

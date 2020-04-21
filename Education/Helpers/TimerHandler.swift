//
//  TimerHandler.swift
//  Education
//
//  Created by Andrey Medvedev on 09/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation
import UIKit

class TimerHandler {
    // onChange returns timeSpent and timeLeft(optional) values
    public var onChange:((TimeInterval, TimeInterval?) -> Void)?
    public var onFinish:(() -> Void)?

    private var timer: Timer?
    private let duration: TimeInterval?
    private var timeLeft: TimeInterval?
    private var timeSpent: TimeInterval
    private let startDate: Date
    private let endDate: Date?
    private var lastActiveDate: Date

    init(withDuration: TimeInterval?) {
        self.duration = withDuration
        self.timeLeft = withDuration
        self.timeSpent = TimeInterval.zero

        let currentDate = Date()
        self.lastActiveDate = currentDate
        self.startDate = currentDate
        if let durationInterval = withDuration {
            self.endDate = currentDate.addingTimeInterval(durationInterval)
        } else {
            self.endDate = nil
        }

        subscribeToNotifications()
    }

    deinit {
        unsubscribeFromNotifications()
    }

    public func getSpentTime() -> TimeInterval {
        return self.timeSpent
    }

    public func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }

    public func startTimer() {
        stopTimer()

//        if #available(iOS 10.0, *) {
//            self.timer = Timer(timeInterval: 1,
//                               repeats: true,
//                               block: { [weak self] _ in
//            })
//        } else {
//        }
        self.timer = Timer(timeInterval: 1,
                           target: self,
                           selector: #selector(handleTimer(sender:)),
                           userInfo: nil,
                           repeats: true)


        self.timer?.fire()
        if let currentTimer = self.timer {
            RunLoop.current.add(currentTimer, forMode: RunLoop.Mode.common)
        }
    }

    // MARK: - Actions
    @objc private func handleTimer(sender: Timer) {
        self.lastActiveDate = Date()

        self.onChange?(self.timeSpent, self.timeLeft)

        self.timeSpent += 1

        if let left = self.timeLeft {
            if left < 1 {
                sender.invalidate()
                self.onFinish?()
            } else {
                self.timeLeft = left - 1
            }
        }
    }

    // MARK: - Notifications
    private var appActiveObserver: Any?
    private var appInactiveObserver: Any?
    private func subscribeToNotifications() {
        appActiveObserver = NotificationCenter.default
            .addObserver(forName: UIApplication.didBecomeActiveNotification,
                         object: nil,
                         queue: nil,
                         using: { [weak self] _ in
                            guard let handler = self else {
                                return
                            }

                            let currentDate = Date()
                            if handler.lastActiveDate > currentDate ||
                                handler.startDate > currentDate {
                                // most likely, time change was made on the device
                                // TODO: decide what to do
                            } else if let dateEnd = handler.endDate,
                                dateEnd < currentDate {
                                // time is over
                                handler.onFinish?()
                            } else {
                                let additionalInterval = currentDate.timeIntervalSince(handler.startDate)
                                handler.timeSpent += additionalInterval
                                if let durationValue = handler.duration {
                                    handler.timeLeft = durationValue - additionalInterval
                                }
                                handler.onChange?(handler.timeSpent, handler.timeLeft)
                            }
            })
        appInactiveObserver = NotificationCenter.default
            .addObserver(forName: UIApplication.willResignActiveNotification,
                         object: nil,
                         queue: nil,
                         using: { [weak self] _ in
                            self?.lastActiveDate = Date()
            })
    }

    private func unsubscribeFromNotifications() {
        if let observer = appActiveObserver {
            appActiveObserver = nil
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = appInactiveObserver {
            appInactiveObserver = nil
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

class RepeatingTimer {

    let timeInterval: TimeInterval

    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }

    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()

    var eventHandler: (() -> Void)?

    private enum State {
        case suspended
        case resumed
    }

    private var state: State = .suspended

    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }

    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }

    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
}

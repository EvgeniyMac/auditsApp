//
//  Date+Additions.swift
//  Education
//
//  Created by Andrey Medvedev on 24/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

extension Date {
    static let dateFormatDefault = "dd.MM.yyyy"
    static let dateFormatReadable = "dd MMMM yyyy"

    static let timeFormatDefault = "HH:mm:ss"
    static let timeFormatReadable = "HH:mm"

    func daysSinceNow() -> Int? {
        let calendar = Calendar.current
        let currentDate = Date()

        let date1 = calendar.startOfDay(for: currentDate)
        let date2 = calendar.startOfDay(for: self)

        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day
    }

    func isInFuture() -> Bool {
        return self > Date()
    }

    func dateTimeString(dateFormat: String?,
                        timeFormat: String?,
                        locale: Locale,
                        timePreposition: String? = nil) -> String {
        var strings = [String]()

        if let dateFormat = dateFormat {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateFormat
            dateFormatter.locale = locale
            strings.append(dateFormatter.string(from: self))
        }

        if let preposition = timePreposition {
            strings.append(preposition)
        }

        if let timeFormat = timeFormat {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = timeFormat
            timeFormatter.locale = locale
            strings.append(timeFormatter.string(from: self))
        }

        return strings.joined(separator: " ")
    }
}

extension Date {
    var startOfDay: Date? {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date? {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components,
                                     to: Calendar.current.startOfDay(for: self))
    }
}

extension Date {
    func isSameDay(as date: Date?) -> Bool {
        return self.startOfDay == date?.startOfDay
    }

    var isToday: Bool {
        return self.isSameDay(as: Date())
    }

    var isYesterday: Bool {
        return self.isSameDay(as: Date().prevDay())
    }
}

extension Date {
    func nextDay() -> Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }

    func prevDay() -> Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }

    func plus(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
}

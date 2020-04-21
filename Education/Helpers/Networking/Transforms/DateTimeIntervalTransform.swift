//
//  DateTimeIntervalTransform.swift
//  Education
//
//  Created by Andrey Medvedev on 20.12.2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import ObjectMapper

open class DateTimeIntervalTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = Double

    private let millisecondsPerSecond = Double(1000)

    public init() {}

    open func transformFromJSON(_ value: Any?) -> Date? {
        if let timeMilliseconds = value as? Double {
            let time = timeMilliseconds / millisecondsPerSecond
            return Date(timeIntervalSince1970: time)
        }

        if let timeStr = value as? String {
            let timeMilliseconds = TimeInterval(atof(timeStr))
            let time = timeMilliseconds / millisecondsPerSecond
            return Date(timeIntervalSince1970: time)
        }

        return nil
    }

    open func transformToJSON(_ value: Date?) -> Double? {
        if let date = value {
            return Double(date.timeIntervalSince1970) * millisecondsPerSecond
        }

        return nil
    }
}

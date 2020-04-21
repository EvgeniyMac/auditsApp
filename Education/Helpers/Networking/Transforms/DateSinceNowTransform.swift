//
//  DateSinceNowTransform.swift
//  Education
//
//  Created by Andrey Medvedev on 17/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import ObjectMapper

open class DateSinceNowTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = Double

    public init() {}

    open func transformFromJSON(_ value: Any?) -> Date? {
        if let timeInt = value as? Double {
            return Date(timeIntervalSinceNow: TimeInterval(timeInt))
        }

        if let timeStr = value as? String {
            return Date(timeIntervalSinceNow: TimeInterval(atof(timeStr)))
        }

        return nil
    }

    open func transformToJSON(_ value: Date?) -> Double? {
        if let date = value {
            return Double(date.timeIntervalSinceNow)
        }

        return nil
    }
}

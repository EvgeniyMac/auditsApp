//
//  StringBoolTransform.swift
//  Education
//
//  Created by Andrey Medvedev on 20/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import ObjectMapper

open class StringBoolTransform: TransformType {
    public typealias Object = Bool
    public typealias JSON = String

    public init() {}

    open func transformFromJSON(_ value: Any?) -> Bool? {
        return (value as? String)?.toBool()
    }

    open func transformToJSON(_ value: Bool?) -> String? {
        if let value = value {
            return value ? "1" : "0"
        }

        return nil
    }
}

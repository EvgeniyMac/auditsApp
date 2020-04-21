//
//  TimeInterval+Additions.swift
//  Education
//
//  Created by Andrey Medvedev on 12/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

extension TimeInterval {
    func readableString() -> String {
        let interval = Int(self)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

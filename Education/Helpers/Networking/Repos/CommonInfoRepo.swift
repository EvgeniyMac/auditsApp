//
//  CommonInfoRepo.swift
//  Education
//
//  Created by Andrey Medvedev on 21/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

class CommonInfoRepo: CommonRepo {
    public static let shared = CommonInfoRepo()

    private var info: CommonStats? {
        didSet {
            NotificationCenter.default.post(name: .DidUpdateStats, object: nil)
        }
    }

    // MARK: - Overridings
    override func clean() {
        super.clean()

        self.info = nil
    }

    // MARK: - Public
    public func getCommonStats() -> CommonStats? {
        return self.info
    }

    public func updateCommonStats(_ stats: CommonStats) {
        self.info = stats
    }
}

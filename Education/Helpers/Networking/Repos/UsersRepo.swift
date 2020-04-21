//
//  UsersRepo.swift
//  Education
//
//  Created by Andrey Medvedev on 05/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

class UsersRepo: CommonRepo {
    public static let shared = UsersRepo()

    private var currentUser: User?

    // MARK: - Overridings
    override func clean() {
        super.clean()

        self.currentUser = nil
    }

    // MARK: - Public
    public func getCurrentUser(refresh: Bool = false) -> User? {
        if refresh {
            loadCurrentUser(completion: nil)
        }
        return self.currentUser
    }

    public func loadCurrentUser(completion: ((User?) -> Void)?) {
        UsersService.getCurrentUser(
            success: { [unowned self] (user) in
                self.currentUser = user
                completion?(user)
            },
            failure: { [unowned self] _ in
                completion?(self.currentUser)
        })
    }
}

//
//  CoursesRepo.swift
//  Education
//
//  Created by Andrey Medvedev on 06/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

class CoursesRepo: CommonRepo {
    public static let shared = CoursesRepo()

    private var activeCourses: [Course]?
    private var inactiveCourses: [Course]?

    // MARK: - Overridings
    override func clean() {
        super.clean()

        self.activeCourses = nil
        self.inactiveCourses = nil
    }

    // MARK: - Public
    public func getActiveCourses(refresh: Bool = false) -> [Course]? {
        if refresh || (self.activeCourses == nil) {
            loadActiveCourses(completion: nil)
        }
        return self.activeCourses
    }

    public func loadActiveCourses(completion: (([Course]?) -> Void)?) {
//        CoursesService.loadActiveCourses(
//            success: { [unowned self] (courses) in
//                self.activeCourses = courses
//                completion?(courses)
//            },
//            failure: { [unowned self] _ in
//                completion?(self.activeCourses)
//        })
    }

    public func getInactiveCourses(refresh: Bool = false) -> [Course]? {
        if refresh || (self.inactiveCourses == nil) {
            loadInactiveCourses(completion: nil)
        }
        return self.inactiveCourses
    }

    public func loadInactiveCourses(completion: (([Course]?) -> Void)?) {
//        CoursesService.loadInactiveCourses(
//            success: { [unowned self] (courses) in
//                self.inactiveCourses = courses
//                completion?(courses)
//            },
//            failure: { [unowned self] _ in
//                completion?(self.inactiveCourses)
//        })
    }

    // MARK: - Private
}

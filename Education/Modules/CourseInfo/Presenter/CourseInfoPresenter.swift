//
//  CourseInfoPresenter.swift
//  Education
//
//  Created by Andrey Medvedev on 20/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

class CourseInfoModuleInput: ModuleInput {

}

class CourseInfoPresenter: CourseInfoModuleInput, CourseInfoViewOutput {

    weak var view: CourseInfoViewInput!
    var router: CourseInfoRouterInput!

    var viewModel: CourseInfoViewModel? {
        didSet {
            self.view.configureWith(viewModel: self.viewModel)
        }
    }

    private var testProceedObserver: Any?
    private var shouldOpenNextMaterial: Bool = false

    deinit {
        unsubscribeFromNotifications()
    }

    // MARK: - CourseInfoModuleInput
    func configureWithObject(_ object: Any) {
    }

    // MARK: - CourseInfoViewOutput
    func viewIsReady() {
        subscribeToNotifications()
    }

    func setupWith(course: Course, onUpdate: (() -> Void)?) {
        self.viewModel = CourseInfoViewModel(withCourse: course,
                                             onUpdate: onUpdate)
    }

    func openMaterial(_ material: Material, from course: Course?) {
        let handler: ((Material) -> Void) = { [weak self] (loadedMaterial) in
            self?.router.openMaterial(
                loadedMaterial,
                from: course,
                onReadLesson: { [weak self] (material, nextMaterialId) in
                    guard let courseId = course?.identifier else {
                        return
                    }
                    self?.loadCourse(identifier: courseId,
                                     completion: { [weak self](updatedCourse) in
                        self?.openMaterial(after: material, from: updatedCourse)
                    })
            })
        }
        loadMaterial(material, from: course, with: handler)
    }

    func openQuestions(for material: Material, from course: Course?) {
        guard let course = course else {
            self.view.showErrorMessage(forError: .insufficientRequestData)
            return
        }

        let handler: ((Material) -> Void) = { [weak self] (loadedMaterial) in
            let questionnaire = Questionnaire(with: loadedMaterial, from: course)
            self?.router.openQuestions(using: questionnaire, from: course)
        }
        loadMaterial(material, from: course, with: handler)
    }

    func runCourse(_ course: Course?) {
        if course?.isMarketCourse == true,
            let courseId = course?.identifier {
            // Market course:
            self.view.showProgressIndicator()
            activateMarketCourse(identifier: courseId) { [weak self] (assignedCourse, error) in
                self?.view.hideProgressIndicator()
                if let assignedCourse = assignedCourse {
                    self?.shouldUpdateCurrentCourse(course: assignedCourse)
                } else if let error = error {
                    let onRetry: (() -> Void) = { [weak self] in
                        self?.runCourse(course)
                    }
                    self?.view.showError(error,
                                         onRetry: onRetry,
                                         onDismiss: nil)
                } else {
                    self?.view.showErrorMessage(forError: .noData)
                }
            }
        } else {
            // Normal course:
            if let material = selectMaterialToRun(from: course) {
                runMaterial(material, from: course)
            }
        }
    }

    private func runMaterial(_ material: Material, from course: Course?) {
        guard let materialType = material.documentType else { return }

        switch materialType {
        case .chapter:
            openMaterial(material, from: course)
        case .test, .exam:
            openQuestions(for: material, from: course)
        }
    }

    private func selectMaterialToRun(from course: Course?) -> Material? {
        if let material = course?.materials?.first(where: { (item) -> Bool in
            return !item.isFinished
        }) {
            // first unfinished material
            return material
        } else {
            // course can be restarted even if it was finished
            return course?.materials?.first
        }
    }

    func shouldUpdateCurrentCourse(course: Course?) {
        guard let courseId = course?.identifier,
            course?.isMarketCourse == false else {
                self.updateWithCourse(nil)
                return
        }

        loadCourse(identifier: courseId) { [weak self] (loadedCourse) in
            self?.updateWithCourse(loadedCourse)

            if self?.shouldOpenNextMaterial == true {
                self?.shouldOpenNextMaterial = false
                self?.runFirstUnfinishedMaterial(for: loadedCourse)
            }
        }
    }

    func shouldAddBookmark(for course: Course?) {
        guard let courseId = course?.identifier else { return }
        FavoritesService.addCourseToFavorites(courseId: courseId,
                                              success: { },
                                              failure: { _ in })
    }

    func shouldRemoveBookmark(for course: Course?) {
        guard let courseId = course?.identifier else { return }
        FavoritesService.removeCourseFromFavorites(courseId: courseId,
                                                   success: { },
                                                   failure: { _ in })
    }

    // MARK: - Private
    private func loadMaterial(_ material: Material,
                              from course: Course?,
                              with handler: ((Material) -> Void)?) {
        guard let materialId = material.identifier,
            let courseId = course?.identifier else {
                self.view.showErrorMessage(forError: .insufficientRequestData)
                return
        }

        self.view.showProgressIndicator()
        CoursesService.loadMaterial(materialId: materialId,
                                    courseId: courseId,
                                    success: { (loadedMaterial) in
                                        self.view.hideProgressIndicator()

                                        // TODO: remove if server will always return material state
                                        loadedMaterial.isActive ??= material.isActive
                                        loadedMaterial.isFailed ??= material.isFailed
                                        loadedMaterial.isPassed ??= material.isPassed
                                        loadedMaterial.remainingAttemptsCount ??= material.remainingAttemptsCount

                                        handler?(loadedMaterial)
        },
                                    failure: { (error) in
                                        let onRetry: (() -> Void) = { [weak self] in
                                            self?.loadMaterial(material,
                                                               from: course,
                                                               with: handler)
                                        }

                                        var onDismiss: (() -> Void)?
                                        switch error {
                                        case .itemNotFound:
                                            onDismiss = { [weak self] in
                                                self?.router.closeModulesStack()
                                            }
                                        default:
                                            onDismiss = nil
                                        }
                                        
                                        self.view.hideProgressIndicator()
                                        self.view.showError(error,
                                                            onRetry: onRetry,
                                                            onDismiss: onDismiss)
        })
    }

    private func activateMarketCourse(identifier: String,
                                      completion: ((Course?, NetworkError?) -> Void)?) {
        CoursesService.activateCourse(courseId: identifier,
                                      success: { (assignedCourse) in
                                        completion?(assignedCourse, nil)
        },
                                      failure: { (error) in
                                        completion?(nil, error)
        })
    }

    private func loadCourse(identifier: String,
                            completion: ((Course?) -> Void)?) {
        self.view.showProgressIndicator()

        CoursesService.loadCourse(
            courseId: identifier,
            success: { (course) in
                self.view.hideProgressIndicator()
                completion?(course)
        },
            failure: { (error) in
                let onRetry: (() -> Void) = { [weak self] in
                    self?.loadCourse(identifier: identifier,
                                     completion: completion)
                }
                let onDismiss: (() -> Void) = { [weak self] in
                    self?.router.closeModulesStack()
                }
                self.view.hideProgressIndicator()
                self.view.showError(error,
                                    onRetry: onRetry,
                                    onDismiss: onDismiss)
                completion?(nil)
        })
    }

    private func runFirstUnfinishedMaterial(for course: Course?) {
        guard let nextMaterial = course?.materials?
            .first(where: { $0.isFinished == false }) else {
                return
        }
        runMaterial(nextMaterial, from: course)
    }

    private func openMaterial(after material: Material, from course: Course?) {
        guard let materials = course?.materials,
            let index = materials.firstIndex(where: { (item) -> Bool in
                return item.identifier == material.identifier
            }) else {
                return
        }

        let newMaterialIndex = index + 1
        if newMaterialIndex < materials.count {
            runMaterial(materials[newMaterialIndex], from: course)
        } else {
            let nonFinished = materials.first(where: { !$0.isFinished })
            if nonFinished == nil {
//                self.router.openResult(for: course)
            }
        }
    }

    private func updateWithCourse(_ course: Course?) {
        guard let vm = self.viewModel,
            let course = course else {
                return
        }

        if course.stats?.status != vm.course.stats?.status {
            NotificationCenter.default.post(name: .DidChangedCourseStatus,
                                            object: nil)

            if let unresolvedMaterials = course.materials?.filter({ !($0.isPassed ?? false) }),
                unresolvedMaterials.isEmpty {
                self.router.openResult(for: course)
            }
        }

        vm.setupCourse(course)
    }

    // MARK: - Notifications
    private func subscribeToNotifications() {
        self.testProceedObserver = NotificationCenter.default
            .addObserver(forName: .DidPassTest,
                         object: nil,
                         queue: nil) { [weak self] notification in
                         self?.shouldOpenNextMaterial = true
        }
    }

    private func unsubscribeFromNotifications() {
        if let observer = testProceedObserver {
            testProceedObserver = nil
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

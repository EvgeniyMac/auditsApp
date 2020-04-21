//
//  MaterialPresenter.swift
//  Education
//
//  Created by Andrey Medvedev on 20/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation
import UIKit

protocol MaterialModuleInput: ModuleInput {
    func configureWith(material: Material?,
                       from course: Course?,
                       onReadLesson: ((Material, String?) -> Void)?)
}

class MaterialPresenter: MaterialModuleInput, MaterialViewOutput {

    weak var view: MaterialViewInput!
    var router: MaterialRouterInput!

    private var material: Material?
    private var course: Course?
    private var onReadLesson: ((Material, String?) -> Void)?
    private let timeTracker = LessonTimeTracker()

    private var appActiveObserver: Any?
    private var appInactiveObserver: Any?

    // MARK: - MaterialModuleInput
    func configureWith(material: Material?,
                       from course: Course?,
                       onReadLesson: ((Material, String?) -> Void)?) {
        self.material = material
        self.course = course
        self.onReadLesson = onReadLesson
        self.view.configureWith(material: material, from: course)
    }

    func shouldMarkLessonAsPassed() {
        guard let material = self.material else { return }
        stopTimeTracking()
        markLessonAsPassed(material: material)
    }

    // MARK: - MaterialViewOutput
    func viewIsReady() {
        subscribeToChangesNotifications()
    }

    func moduleDeinited() {
        unsubscribeFromChangesNotifications()
    }

    func viewDidAppear() {
        startTimeTracking()
    }

    func viewWillDisappear() {
        stopTimeTracking()
    }

    func openQuestions(using questionnaire: Questionnaire) {
        self.router.openQuestions(using: questionnaire)
    }

    // MARK: - Private
    private func markLessonAsPassed(material: Material) {
        if material.isPassed == true {
            self.router.closeModule()
            return
        }

        guard let courseId = course?.identifier,
            let materialId = material.identifier else {
                self.view.showErrorMessage(forError: .insufficientRequestData)
                return
        }

        self.view.showProgressIndicator()
        MaterialsService.markLessonAsPassed(
            courseId: courseId,
            materialId: materialId,
            success: { [weak self] (nextMaterial) in
                self?.view.hideProgressIndicator()
                self?.router.closeModule()
                self?.onReadLesson?(material, nextMaterial.identifier)
            },
            failure: { [weak self] (error) in
                let onRetry: (() -> Void) = { [weak self] in
                    self?.markLessonAsPassed(material: material)
                }
                self?.view.hideProgressIndicator()
                self?.view.showError(error,
                                     onRetry: onRetry,
                                     onDismiss: nil)
        })
    }

    private func startTimeTracking() {
        guard let materialType = self.material?.documentType,
            materialType == .chapter,
            self.material?.isFinished == false else {
                // tracking time only for non-finished lessons
                return
        }

        self.timeTracker.start()
    }

    private func stopTimeTracking() {
        guard let materialType = self.material?.documentType,
            materialType == .chapter,
            self.material?.isFinished == false else {
                // tracking time only for non-finished lessons
                return
        }

        if self.timeTracker.state == .tracking {
            self.timeTracker.stop()
            if let material = self.material,
                let spentTime = self.timeTracker.duration {
                self.timeTracker.reset()
                self.reportLessonSpentTime(material: material,
                                           spentTime: Int(spentTime))
            }
        }
    }

    private func reportLessonSpentTime(material: Material, spentTime: Int) {
        if material.isPassed == true {
            return
        }

        guard let courseId = course?.identifier,
            let materialId = material.identifier else {
                self.view.showErrorMessage(forError: .insufficientRequestData)
                return
        }

        MaterialsService.reportLessonSpentTime(courseId: courseId,
                                               materialId: materialId,
                                               spentTime: spentTime,
                                               success: { },
                                               failure: { _ in })
    }

    // MARK: - Notifications
    private func subscribeToChangesNotifications() {
        self.appActiveObserver = NotificationCenter.default
            .addObserver(forName: UIApplication.didBecomeActiveNotification,
                         object: nil,
                         queue: nil) { [weak self] _ in
                            self?.startTimeTracking()
        }
        self.appInactiveObserver = NotificationCenter.default
            .addObserver(forName: UIApplication.willResignActiveNotification,
                         object: nil,
                         queue: nil) { [weak self] _ in
                            self?.stopTimeTracking()
        }
    }

    private func unsubscribeFromChangesNotifications() {
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

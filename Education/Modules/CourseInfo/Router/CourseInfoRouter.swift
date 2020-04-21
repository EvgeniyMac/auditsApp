//
//  CourseInfoRouter.swift
//  Education
//
//  Created by Andrey Medvedev on 20/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

protocol CourseInfoRouterInput {
    func openQuestions(using questionnaire: Questionnaire, from course: Course?)
    func openMaterial(_ material: Material,
                      from course: Course?,
                      onReadLesson: ((Material, String?) -> Void)?)
    func openResult(for course: Course?)
    func closeModulesStack()
}

class CourseInfoRouter: CourseInfoRouterInput {

    weak var transitionHandler: TransitionHandlerProtocol!

    func openMaterial(_ material: Material,
                      from course: Course?,
                      onReadLesson: ((Material, String?) -> Void)?) {
        self.transitionHandler.openModule(segueIdentifier: "toMaterialViewController",
                                          configurate: { (moduleInput) in
                                            if let moduleInput = moduleInput as? MaterialModuleInput {
                                                moduleInput.configureWith(material: material,
                                                                          from: course,
                                                                          onReadLesson: onReadLesson)
                                            }
        })
    }

    func openQuestions(using questionnaire: Questionnaire, from course: Course?) {
        self.transitionHandler.openModule(segueIdentifier: "toQuestionViewController",
                                          configurate: { (moduleInput) in
                                            if let moduleInput = moduleInput as? QuestionModuleInput {
                                                moduleInput.configureWith(questionnaire: questionnaire,
                                                                          questionIndex: 0)
                                            }
        })
    }

    func openResult(for course: Course?) {
        self.transitionHandler.openModule(segueIdentifier: "toResultViewController",
                                          configurate: { (moduleInput) in
                                            if let moduleInput = moduleInput as? ResultModuleInput {
                                                var latest: Questionnaire? = nil
                                                if let questionnaire = QuestionnaireManager.shared.latest,
                                                    let courseId = course?.identifier,
                                                    courseId == questionnaire.course.identifier {
                                                        // checking that the questionnaire belongs to the course
                                                        latest = questionnaire
                                                }
                                                moduleInput.configureWith(questionnaire: latest,
                                                                          course: course)
                                            }
        })
    }

    func closeModulesStack() {
        self.transitionHandler.closeModulesStack()
    }
}

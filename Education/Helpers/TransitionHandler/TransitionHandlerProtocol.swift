//
//  TransitionHandlerProtocol.swift
//  Education
//
//  Created by Andrey Medvedev on 20/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

typealias ModuleConfiguration = (ModuleInput?) -> Void

protocol TransitionHandlerProtocol: class {

    func openModule(segueIdentifier: String, configurate: ModuleConfiguration?)
    func openModule(storyboardName: String,
                    storyboardID: String,
                    configurate: ModuleConfiguration?,
                    isFromLeftAnimation: Bool?)
    func closeModule()
    func closeModulesStack()

    func descendToViewController(withPredicate predicate: ((UIViewController) -> Bool))

    func presentModule(storyboardName: String,
                       storyboardID: String,
                       configurate: ModuleConfiguration?)
    func dismissModule()

}

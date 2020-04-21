//
//  UIViewController+TransitionHandlerProtocol.swift
//  Education
//
//  Created by Andrey Medvedev on 20/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

extension UIViewController: TransitionHandlerProtocol {

    func openModule(segueIdentifier: String, configurate: ModuleConfiguration?) {
        performSegueWithIdentifier(identifier: segueIdentifier,
                                   sender: self) { [weak self] (segue) in
                                    guard configurate != nil else {
                                        return
                                    }

                                    if let moduleInput = self?.moduleInputFor(segue.destination) {
                                        configurate?(moduleInput)
                                    }
        }
    }

    func openModule(storyboardName: String,
                    storyboardID: String,
                    configurate: ModuleConfiguration?,
                    isFromLeftAnimation: Bool?) {
        let storyboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: storyboardID)

        if let configurate = configurate, let moduleInput = moduleInputFor(vc) {
            configurate(moduleInput)
        }

        if let navController = self.navigationController {
            if let fromLeft = isFromLeftAnimation {
                if fromLeft == true {
                    pushWithType(CATransitionSubtype.fromLeft, viewController: vc)
                } else {
                    pushWithType(CATransitionSubtype.fromRight, viewController: vc)
                }
            } else {
                navController.pushViewController(vc, animated: true)
            }
        }
    }

    func closeModule() {
        // Probably, this is not working properly
//        if self.hasParentViewController() {
//            self.navigationController?.popViewController(animated: true)
//        } else if self.isModal() {
//            self.dismiss(animated: true, completion: nil)
//        } else {
//
//        }

        self.navigationController?.popViewController(animated: true)
    }

    func closeModulesStack() {
        self.navigationController?.popToRootViewController(animated: true)
    }

    func descendToViewController(withPredicate predicate: ((UIViewController) -> Bool)) {
        if let destinationVC = self.navigationController?.viewControllers.last(where: predicate) {
            self.navigationController?.popToViewController(destinationVC, animated: true)
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    func presentModule(storyboardName: String,
                       storyboardID: String,
                       configurate: ModuleConfiguration?) {
        let storyboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: storyboardID)

        if let configurate = configurate, let moduleInput = moduleInputFor(vc) {
            configurate(moduleInput)
        }

        if let navController = self.navigationController {
            navController.present(vc, animated: true, completion: nil)
        } else {
            self.present(vc, animated: true, completion: nil)
        }
    }

    func dismissModule() {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Private
    private func pushWithType(_ type: CATransitionSubtype, viewController: UIViewController) {
        guard let navController = self.navigationController else {
            return
        }

        let transition = CATransition()
        transition.duration = 0.35
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = type
        navController.view.layer.add(transition, forKey: nil)
        navController.pushViewController(viewController, animated: false)
    }

    private func hasParentViewController() -> Bool {
        return self.navigationController?.parent != nil
    }

    private func isModal() -> Bool {
        if self.presentingViewController != nil {
            return true
        } else if self.navigationController?.presentingViewController?.presentedViewController == self.navigationController {
            return true
        } else if self.tabBarController?.presentingViewController is UITabBarController {
            return true
        }

        return false
    }

    private func moduleInputFor(_ vc: UIViewController) -> ModuleInput? {
        var neededController: UIViewController = vc

        if vc is UINavigationController {
            if let navigationController = vc as? UINavigationController,
                let topController = navigationController.topViewController {
                neededController = topController
            }
        }

        if let value = valueFor(property: "output", of: neededController) {
            return value as? ModuleInput
        }

        return nil
    }

    private func isNilDescendant(_ any: Any?) -> Bool {
        return String(describing: any) == "Optional(nil)"
    }

    private func valueFor(property: String, of object: Any) -> Any? {
        let mirror = Mirror(reflecting: object)
        if let child = mirror.descendant(property), !isNilDescendant(child) {
            return child
        } else {
            return nil
        }
    }
}

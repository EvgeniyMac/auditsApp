//
//  UIViewController+Routing.swift
//  Education
//
//  Created by Andrey Medvedev on 20/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class Box {
    let value: Any
    init(_ value: Any) {
        self.value = value
    }
}

public extension DispatchQueue {

    private static var _onceTracker = [String]()

    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.

     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block:() -> Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }

        if _onceTracker.contains(token) {
            return
        }

        _onceTracker.append(token)
        block()
    }
}

extension UIViewController {

    struct AssociatedKey {
        static var ClosurePrepareForSegueKey = "ClosurePrepareForSegueKey"
    }

    typealias ConfiguratePerformSegue = (UIStoryboardSegue) -> Void
    func performSegueWithIdentifier(identifier: String, sender: AnyObject?, configurate: ConfiguratePerformSegue?) {
        swizzlingPrepareForSegue()
        configuratePerformSegue = configurate
        performSegue(withIdentifier: identifier, sender: sender)
    }

    private func swizzlingPrepareForSegue() {
        DispatchQueue.once(token: "simple_router_token") {
            let originalSelector = #selector(UIViewController.prepare)
            let swizzledSelector = #selector(UIViewController.closurePrepareForSegue(segue:sender:))

            let instanceClass = UIViewController.self
            let originalMethod = class_getInstanceMethod(instanceClass, originalSelector)
            let swizzledMethod = class_getInstanceMethod(instanceClass, swizzledSelector)

            let didAddMethod = class_addMethod(instanceClass,
                                               originalSelector,
                                               method_getImplementation(swizzledMethod!),
                                               method_getTypeEncoding(swizzledMethod!))

            if didAddMethod {
                class_replaceMethod(instanceClass,
                                    swizzledSelector,
                                    method_getImplementation(originalMethod!),
                                    method_getTypeEncoding(originalMethod!))
            } else {
                method_exchangeImplementations(originalMethod!, swizzledMethod!)
            }
        }
    }

    @objc func closurePrepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        configuratePerformSegue?(segue)
        closurePrepareForSegue(segue: segue, sender: sender)
        configuratePerformSegue = nil
    }

    var configuratePerformSegue: ConfiguratePerformSegue? {
        get {
            let box = objc_getAssociatedObject(self, &AssociatedKey.ClosurePrepareForSegueKey) as? Box
            return box?.value as? ConfiguratePerformSegue
        }
        set {
            if newValue != nil {
                objc_setAssociatedObject(self, &AssociatedKey.ClosurePrepareForSegueKey, Box(newValue!), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
    }
}

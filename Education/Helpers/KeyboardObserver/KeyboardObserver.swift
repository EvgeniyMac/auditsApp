//
//  KeyboardObserver.swift
//  Education
//
//  Created by Andrey Medvedev on 02/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation
import UIKit

protocol KeyboardObserver {
    func subscribeToKeyboardNotifications(keyboardOffsetHandler: @escaping (CGFloat) -> Void)
    func unsubscribeFromKeyboardNotifications()
}

extension UIViewController {

    fileprivate static let associationShow = ObjectAssociation<NSObject>()
    var keyboardWillShowObserver: NSObjectProtocol? {
        get { return UIViewController.associationShow[self] }
        set { UIViewController.associationShow[self] = newValue as? NSObject }
    }

    fileprivate static let associationHide = ObjectAssociation<NSObject>()
    var keyboardWillHideObserver: NSObjectProtocol? {
        get { return UIViewController.associationHide[self] }
        set { UIViewController.associationHide[self] = newValue as? NSObject }
    }
}

extension KeyboardObserver where Self: UIViewController {
    // MARK: - Notifications handling
    func subscribeToKeyboardNotifications(keyboardOffsetHandler: @escaping (CGFloat) -> Void) {
        keyboardWillShowObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: nil) { [weak self] (notification) in
                self?.handleNotification(notification, keyboardOffsetHandler: keyboardOffsetHandler)
        }
        keyboardWillHideObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: nil) { [weak self] (notification) in
                self?.handleNotification(notification, keyboardOffsetHandler: keyboardOffsetHandler)
        }
    }

    func unsubscribeFromKeyboardNotifications() {
        if let observer = keyboardWillShowObserver {
            NotificationCenter.default.removeObserver(observer)
            keyboardWillShowObserver = nil
        }
        if let observer = keyboardWillHideObserver {
            NotificationCenter.default.removeObserver(observer)
            keyboardWillHideObserver = nil
        }
    }

    private func handleNotification(
        _ notification: Notification,
        keyboardOffsetHandler: (CGFloat) -> Void) {
        if notification.name == UIResponder.keyboardWillShowNotification {
            var keyboardHeight: CGFloat = 0.0
            if let keyboardFrame: NSValue =
                notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                keyboardHeight = keyboardFrame.cgRectValue.height
            }

            keyboardOffsetHandler(keyboardHeight)
        } else if notification.name == UIResponder.keyboardWillHideNotification {
            keyboardOffsetHandler(0.0)
        }
    }
}

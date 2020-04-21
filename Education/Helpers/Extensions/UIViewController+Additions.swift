//
//  UIViewController+Additions.swift
//  Education
//
//  Created by Andrey Medvedev on 17/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

extension UIViewController {
    func showError(_ error: NetworkError,
                   onRetry: (() -> Void)?,
                   onDismiss: (() -> Void)? = nil) {
        switch error {
        case .unauthorized:
            showErrorMessage(withText: error.localizedDescription,
                             onDismiss: {
                                UserManager.logout()
            })
        case .deprecatedVersion:
            showErrorMessage(withText: error.localizedDescription,
                             onDismiss: {
                                Utilities.openAppInAppStore()
            })
        case .noInternetConnection,
             .userBlocked,
             .serverError(_):
            showErrorScreen(error: error, onRetry: onRetry)
        case .itemNotFound:
            showErrorMessage(withText: error.localizedDescription,
                             onDismiss: onDismiss)
        default:
            showErrorMessage(withText: error.localizedDescription)
        }
    }

    func showErrorMessage(forError error: NetworkError) {
        showErrorMessage(withText: error.localizedDescription)
    }

    func showErrorMessage(withText text: String) {
        showErrorMessage(withText: text, onDismiss: nil)
    }

    func showErrorMessage(withText text: String,
                          onDismiss: (() -> Void)?) {
        let alert = UIAlertController(title: Localization.string("common.error"),
                                      message: text,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localization.string("common.ok"),
                                      style: .cancel,
                                      handler: { _ in
                                        onDismiss?()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func requestConfirmation(action: (() -> Void)?,
                             message: String,
                             confirmText: String,
                             declineText: String) {
        let alert = UIAlertController(title: nil,
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: confirmText,
                                      style: .default,
                                      color: AppStyle.Color.textMain,
                                      handler: { _ in
                                        action?()
        }))
        alert.addAction(UIAlertAction(title: declineText,
                                      style: .cancel,
                                      color: AppStyle.Color.textMain,
                                      handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    func showErrorScreen(error: NetworkError?,
                         onRetry: (() -> Void)?) {
        let vc = ConnectionErrorViewController()
        vc.error = error
        vc.onPressAction = { [weak vc] in
            vc?.view.removeFromSuperview()
            vc?.removeFromParent()
            onRetry?()
        }
        addChildViewController(vc, to: self.view)
        self.view.bringSubviewToFront(vc.view)
    }

    func showBlockScreen(error: NetworkError?,
                         onRetry: (() -> Void)?) {
        let vc = ConnectionErrorViewController()
        vc.error = error
        vc.onPressAction = { [weak vc] in
            vc?.view.removeFromSuperview()
            vc?.removeFromParent()
            onRetry?()
        }
        addChildViewController(vc, to: self.view)
        self.view.bringSubviewToFront(vc.view)
    }
}

extension UIViewController: NVActivityIndicatorViewable {
    func showProgressIndicator() {
        startAnimating(type: NVActivityIndicatorType.ballSpinFadeLoader)
    }

    func hideProgressIndicator() {
        stopAnimating()
    }
}

extension UIViewController {
    func isTopmost() -> Bool {
        return UIApplication.shared.keyWindow?.visibleViewController == self
    }
}

extension UIViewController {
    func addChildViewController(_ vc: UIViewController,
                                to containerView: UIView) {
        vc.willMove(toParent: self)
        self.addChild(vc)
        vc.beginAppearanceTransition(true, animated: true)
        containerView.addSubview(vc.view)
        vc.endAppearanceTransition()
        vc.didMove(toParent: self)
        vc.view.frame = containerView.bounds

        vc.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = containerView.createContiguousConstraints(toView: vc.view)
        containerView.addConstraints(constraints)
    }
}

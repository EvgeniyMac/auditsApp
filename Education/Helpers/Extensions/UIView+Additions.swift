//
//  UIView+Additions.swift
//  Education
//
//  Created by Andrey Medvedev on 23/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

extension UIView {
    static func fromNib<T: UIView>() -> T? {
        let nibViews = Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)
        return nibViews?.first(where: { (nibView) -> Bool in return nibView is T }) as? T
    }

    func createContiguousConstraints(toView view: UIView,
                                     insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        return [self.createContiguousConstraint(toItem: view, attribute: .top, inset: insets.top),
                self.createContiguousConstraint(toItem: view, attribute: .left, inset: insets.left),
                self.createContiguousConstraint(toItem: view, attribute: .right, inset: -insets.right),
                self.createContiguousConstraint(toItem: view, attribute: .bottom, inset: -insets.bottom)]
    }

    func createContiguousConstraint(toItem: Any,
                                    attribute: NSLayoutConstraint.Attribute,
                                    inset: CGFloat = 0.0) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self,
                                  attribute: attribute,
                                  relatedBy: .equal,
                                  toItem: toItem,
                                  attribute: attribute,
                                  multiplier: 1.0,
                                  constant: -inset)
    }

    func createProportionalConstraint(toItem: Any,
                                      attribute: NSLayoutConstraint.Attribute,
                                      ratio: CGFloat = 1.0,
                                      inset: CGFloat = 0.0) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self,
                                  attribute: attribute,
                                  relatedBy: .equal,
                                  toItem: toItem,
                                  attribute: attribute,
                                  multiplier: ratio,
                                  constant: -inset)
    }

    func createSizeConstraints(size: CGSize) -> [NSLayoutConstraint] {
        return [NSLayoutConstraint(item: self,
                                   attribute: .height,
                                   relatedBy: .equal,
                                   toItem: nil,
                                   attribute: .notAnAttribute,
                                   multiplier: 1.0,
                                   constant: size.height),
                NSLayoutConstraint(item: self,
                                   attribute: .width,
                                   relatedBy: .equal,
                                   toItem: nil,
                                   attribute: .notAnAttribute,
                                   multiplier: 1.0,
                                   constant: size.width)]
    }

    func createRatioConstraint(ratio: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self,
                                  attribute: .width,
                                  relatedBy: .equal,
                                  toItem: self,
                                  attribute: .height,
                                  multiplier: ratio,
                                  constant: 0.0)
    }

    func addSizeConstraints(width: CGFloat? = nil, height: CGFloat? = nil) {
        if let width = width {
            self.addConstraint(NSLayoutConstraint(item: self,
                                                  attribute: .width,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1.0,
                                                  constant: width))
        }

        if let height = height {
            self.addConstraint(NSLayoutConstraint(item: self,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1.0,
                                                  constant: height))
        }
    }
}

extension UIView {
    func toImage(background: UIColor?) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        // setting background color
        background?.set()

        self.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
}

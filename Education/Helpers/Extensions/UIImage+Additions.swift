//
//  UIImage+Additions.swift
//  Education
//
//  Created by Andrey Medvedev on 05.03.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import UIKit

extension UIImage {

    var widthRatio: CGFloat {
        return self.size.width / self.size.height
    }

    var heightRatio: CGFloat {
        return self.size.height / self.size.width
    }

    func resize(to newSize: CGSize) -> UIImage? {
        let newFrame = CGRect(origin: .zero, size: newSize)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: newFrame)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func resize(toMaxSide maxSide: CGFloat) -> UIImage? {
        if self.size.width > self.size.height {
            return self.resize(to: CGSize(width: maxSide, height: maxSide * self.heightRatio))
        } else {
            return self.resize(to: CGSize(width: maxSide * self.widthRatio, height: maxSide))
        }
    }
}

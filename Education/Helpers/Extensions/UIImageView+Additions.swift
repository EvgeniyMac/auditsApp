//
//  UIImageView+Additions.swift
//  Education
//
//  Created by Andrey Medvedev on 03/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit
import AlamofireImage

extension UIImageView {
    func setImage(withUrl url: URL, placeholder: UIImage? = nil) {
        af_setImage(withURL: url,
                    placeholderImage: placeholder,
                    filter: nil,
                    progress: nil,
                    progressQueue: DispatchQueue.main,
                    imageTransition: UIImageView.ImageTransition.noTransition,
                    runImageTransitionIfCached: false,
                    completion: nil)
    }
}

extension UIImage {
    public convenience init?(color: UIColor,
                             size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

//
//  ImageTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 30/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit
import AlamofireImage

class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!

    func loadImageFromUrl(_ url: URL?,
                          placeholderImage: UIImage?,
                          minRatio: CGFloat,
                          completion: ((UIImage?) -> Void)?) {
        self.mainImageView.image = placeholderImage

        guard let url = url else {
            completion?(placeholderImage)
            return
        }

        self.mainImageView.af_setImage(
            withURL: url,
            placeholderImage: placeholderImage,
            filter: nil,
            progress: nil,
            progressQueue: DispatchQueue.main,
            imageTransition: .noTransition,
            runImageTransitionIfCached: false,
            completion: { [weak self] (dataResponse) in
                guard let selfWidth = self?.frame.width else { return }
                guard let image = dataResponse.result.value, image.size.height > 0 else {
                    if let placeholderSize = placeholderImage?.size {
                        let placeholderRatio = placeholderSize.width / placeholderSize.height
                        self?.applyImageRatio(max(minRatio, placeholderRatio))
                    } else {
                        self?.applyImageRatio(minRatio)
                    }
                    return
                }

                let imageRatio = image.size.width / image.size.height
                let ratio = max(minRatio, imageRatio)
                let newHeight = (ratio > 0) ? (selfWidth / ratio) : CGFloat.zero
                if let oldHeight = self?.imageHeightConstraint.constant,
                    abs(oldHeight - newHeight) > 1.0 {

                    // WORKAROUND: workaround for reloading image size
                    DispatchQueue.main.async {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self?.imageHeightConstraint.constant = newHeight
                        completion?(image)
                    }
                }
        })
    }

    private func applyImageRatio(_ ratio: CGFloat) {
        if ratio > CGFloat.zero {
            self.imageHeightConstraint.constant = self.frame.width / ratio
        } else {
            self.imageHeightConstraint.constant = CGFloat.zero
        }
    }
}

//
//  AnswerImageTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 19/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class AnswerImageTableViewCell: UITableViewCell {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var mainImageHeightConstraint: NSLayoutConstraint!

    var isLoadedImage = false

    func loadImage(fromUrl url: URL,
                   maxSize: CGSize,
                   completion: ((UIImage?) -> Void)?) {
        self.mainImageView.af_setImage(
            withURL: url,
            placeholderImage: nil,
            filter: nil,
            progress: nil,
            progressQueue: DispatchQueue.main,
            imageTransition: .noTransition,
            runImageTransitionIfCached: false,
            completion: { [weak self] (dataResponse) in
                var cellHeight = CGFloat.zero
                if let image = dataResponse.result.value,
//                    let cellWidth = self?.frame.width,
                    image.size.height != CGFloat.zero {
                    let imageRatio = image.size.width / image.size.height
                    if imageRatio > 0 {
                        cellHeight = maxSize.width / imageRatio
                    }
                }
                self?.mainImageHeightConstraint.constant = min(cellHeight, maxSize.height)

                completion?(dataResponse.result.value)
        })
    }

    func updateWithImage(_ image: UIImage?,
                         maxSize: CGSize) {
        var cellHeight = CGFloat.zero
        if let image = image,
            image.size.height != 0 {
            let imageRatio = image.size.width / image.size.height
            if imageRatio > 0 {
                cellHeight = maxSize.width / imageRatio
            }
        }
        self.mainImageHeightConstraint.constant = min(cellHeight, maxSize.height)
        self.mainImageView?.image = image
    }
}

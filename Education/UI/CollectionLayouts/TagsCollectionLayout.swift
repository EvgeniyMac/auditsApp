//
//  TagsCollectionLayout.swift
//  Education
//
//  Created by Andrey Medvedev on 26/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class TagsCollectionLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = copy(super.layoutAttributesForElements(in: rect))
        attributes?.filter({ $0.representedElementCategory == .cell })
            .forEach({ (layoutAttributes) in
                let indexPath = layoutAttributes.indexPath
                if let newFrame = layoutAttributesForItem(at: indexPath)?.frame {
                    layoutAttributes.frame = newFrame
                }
            })
        return attributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath)?
            .copy() as? UICollectionViewLayoutAttributes else {
                return nil
        }

        let currentFrame = attributes.frame

        guard indexPath.item > 0 else {
            return attributes
        }

//        if (indexPath.item < numColumns){
//            CGRect f = currentItemAttributes.frame;
//            f.origin.y = 0;
//            currentItemAttributes.frame = f;
//            return currentItemAttributes;
//        }
//        NSIndexPath* ipPrev = [NSIndexPath indexPathForItem:indexPath.item-numColumns inSection:indexPath.section];
//        CGRect fPrev = [self layoutAttributesForItemAtIndexPath:ipPrev].frame;
//        CGFloat YPointNew = fPrev.origin.y + fPrev.size.height + 10;
//        CGRect f = currentItemAttributes.frame;
//        f.origin.y = YPointNew;
//        currentItemAttributes.frame = f;

        return attributes
    }

    // MARK: - Private
    private func copy(_ layoutAttributesArray: [UICollectionViewLayoutAttributes]?) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributesArray?.map{ $0.copy() } as? [UICollectionViewLayoutAttributes]
    }
}

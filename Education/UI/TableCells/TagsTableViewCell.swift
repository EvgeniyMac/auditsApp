//
//  TagsTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 11/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit
import AlignedCollectionViewFlowLayout

class TagsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet private weak var collectionHeightConstraint: NSLayoutConstraint!

    var onNeedUpdateHeight: (() -> Void)?

    private let tagItemHeight: CGFloat = 30
    private let tagsInteritemSpacing: CGFloat = 8
    private let tagsLineSpacing: CGFloat = 8

    private var tags = [String]()

    override func awakeFromNib() {
        super.awakeFromNib()

        self.titleLabel.textColor = AppStyle.Color.textMain
        self.titleLabel.font = AppStyle.Font.medium(20)
        self.titleLabel.numberOfLines = 0

        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let tagItemWidth = collectionView.frame.width / 4
            let cellSize = CGSize(width: tagItemWidth, height: tagItemHeight)
            layout.estimatedItemSize = cellSize
            layout.minimumInteritemSpacing = tagsInteritemSpacing
            layout.minimumLineSpacing = tagsLineSpacing
        }

        if let layout = self.collectionView.collectionViewLayout as? AlignedCollectionViewFlowLayout {
            layout.horizontalAlignment = .left
            layout.verticalAlignment = .top
        }

        let cellId = TextCollectionViewCell.viewReuseIdentifier()
        self.collectionView.register(UINib(nibName: cellId, bundle: nil),
                                     forCellWithReuseIdentifier: cellId)
    }

    // MARK: - Public
    public func setupWithTags(_ tags: [String]) {
        self.tags = tags
        self.collectionView.reloadData()

        self.collectionView.collectionViewLayout.invalidateLayout()
        DispatchQueue.main.async { [weak self] in
            if let collectionLayout = self?.collectionView.collectionViewLayout {
                let collectionSize = collectionLayout.collectionViewContentSize
                self?.collectionHeightConstraint.constant = collectionSize.height

                self?.onNeedUpdateHeight?()
            }
        }
    }
}

extension TagsTableViewCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tags.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TextCollectionViewCell = collectionView.dequeCell(at: indexPath)

        let tagItem = self.tags[indexPath.row]
        cell.textLabel.text = tagItem
        cell.textLabel.textColor = AppStyle.Color.darkGray
        cell.textLabel.textAlignment = .center

        cell.container.backgroundColor = AppStyle.Color.backgroundSecondary
        cell.container.layer.cornerRadius = AppStyle.CornerRadius.tag
        cell.container.layer.masksToBounds = true

        return cell
    }
}

extension TagsTableViewCell: UICollectionViewDelegate {

}

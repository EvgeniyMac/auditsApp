//
//  AuditTilesTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 14.03.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import UIKit

class AuditTilesTableViewCell: UITableViewCell {

    public var onPressPhoto: ((UIImage?) -> Void)?
    public var onPressAddPhotoButton: (() -> Void)?

    @IBOutlet private weak var collectionView: UICollectionView!

    private var shouldShowAddPhotos: Bool = false
    private var shouldShowAddVideos: Bool = false
    private var urls = [URL(string: "https://media.dev.7skills.com/files/5e7a0d1773a6124db9077648"), URL(string: "https://media.dev.7skills.com/files/5e7a0d1773a6124db9077648"), URL(string: "https://media.dev.7skills.com/files/5e7a0d1773a6124db9077648")]
    private var photosToSend: Int = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = AppStyle.Color.custom(hex: 0xEEEEEE)
        self.contentView.backgroundColor = AppStyle.Color.custom(hex: 0xEEEEEE)
        self.collectionView.backgroundColor = AppStyle.Color.custom(hex: 0xEEEEEE)
                
        [ImageCollectionViewCell.viewReuseIdentifier(),
         AddMediaCollectionViewCell.viewReuseIdentifier()].forEach { (cellId) in
         let nib = UINib(nibName: cellId, bundle: nil)
         self.collectionView.register(nib, forCellWithReuseIdentifier: cellId)
        }
        if let layout = self.collectionView
            .collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
    }

    func setup(with urls: [URL], auditQuestion: AuditQuestion) {
  //      self.urls.removeAll()
        self.urls.append(contentsOf: urls)
        setup(with: auditQuestion)
    }
}

extension AuditTilesTableViewCell: AuditQuestionTableViewCellProtocol {
    func setup(with auditQuestion: AuditQuestion) {
        if auditQuestion.userAnswer?.answer == nil {
            self.shouldShowAddVideos = auditQuestion.canSendVideo

            let sent = self.urls.count
            let limit = auditQuestion.photoPreferences?.count ?? 0
            self.photosToSend = limit - sent
            switch auditQuestion.photoPreferences?.requirement {
            case .required, .optional:
                self.shouldShowAddPhotos = sent < limit
            case .no:
                self.shouldShowAddPhotos = false
            default:
                self.shouldShowAddPhotos = false
            }
        } else {
            self.shouldShowAddPhotos = false
            self.shouldShowAddVideos = false
        }

        self.collectionView.reloadData()
    }
}

extension AuditTilesTableViewCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.urls.count
        case 1:
            return self.shouldShowAddPhotos ? 1 : 0
        case 2:
            return self.shouldShowAddVideos ? 1 : 0
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeCell(at: indexPath) as ImageCollectionViewCell
            guard let url = self.urls[indexPath.row] else { return UICollectionViewCell() }
//            let stringUrl = "https://media.dev.7skills.com/files/5e7a0d1773a6124db9077648"
//            guard let urlString = URL(string: stringUrl) else { return UICollectionViewCell() }
            cell.imageView.setImage(withUrl: url, placeholder: nil)
            return cell
        case 1:
            let cell = collectionView.dequeCell(at: indexPath) as AddMediaCollectionViewCell
            cell.setupAsPhoto()
            cell.infoLabel.text = String(self.photosToSend)

            print(self.photosToSend)
            return cell
        case 2:
            let cell = collectionView.dequeCell(at: indexPath) as AddMediaCollectionViewCell
            cell.setupAsVideo()
            return cell
        default:
            fatalError("Unknown section at AuditTilesTableViewCell")
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell
            self.onPressPhoto?(cell?.imageView.image)
        case 1:
            self.onPressAddPhotoButton?()
        case 2:
            break
        default:
            fatalError("Unknown section at AuditTilesTableViewCell")
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(width: 55, height: 64)
        case 1,2:
            return CGSize(width: 54, height: 54)
        default:
            return CGSize.zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch section {
        case 0:
            return UIEdgeInsets(top: 0, left: 19, bottom: 19, right: 0)
        case 1,2:
            return UIEdgeInsets(top: 0, left: 6, bottom: 10, right: 0)
        default:
            return UIEdgeInsets.zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch section {
        case 0:
            return 10
        default:
            return CGFloat.zero
        }
    }

}

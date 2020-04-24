//
//  AuditImagePreviewTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 18.03.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import UIKit

class AuditImagePreviewTableViewCell: UITableViewCell {

    public var onSelectPhotoForPreview: ((Int) -> Void)?
    public var onPressAddPhotoButton: (() -> Void)?

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var largeImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet private weak var imageHeightConstraint: NSLayoutConstraint!

    private var shouldShowAddPhotos: Bool = false
    private var shouldShowAddVideos: Bool = false
    private var urls = [URL]()
    private var photosToSend: Int = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = AppStyle.Color.custom(hex: 0xFFFFFF)
        self.contentView.backgroundColor = AppStyle.Color.custom(hex: 0xFFFFFF)
        self.stackView.spacing = 18

        self.collectionView.allowsMultipleSelection = false
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

    func setup(with urls: [URL], selectedIndex: Int?, auditQuestion: AuditQuestion) {
        self.urls.removeAll()
        self.urls.append(contentsOf: urls)

        if let index = selectedIndex, index < urls.count {
            let path = IndexPath(item: index, section: 0)
            self.collectionView.selectItem(at: path,
                                           animated: false,
                                           scrollPosition: .left)

            self.setupLargeImage(withUrl: urls[index])
        } else {
            self.largeImageView.image = nil
        }

        setup(with: auditQuestion)
    }

    private func setupLargeImage(withUrl url: URL) {
        let minRatio: CGFloat = 0.3
        let placeholderImage: UIImage? = nil

        self.largeImageView.af_setImage(
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

                self?.config(heightConstraint: self?.imageHeightConstraint,
                             using: image,
                             cellWidth: selfWidth,
                             minRatio: minRatio)
        })
    }
}

extension AuditImagePreviewTableViewCell: AuditQuestionTableViewCellProtocol {
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

extension AuditImagePreviewTableViewCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

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
            let url = self.urls[indexPath.row]
            cell.imageView.setImage(withUrl: url, placeholder: nil)
            setup(imageCell: cell, asSelected: cell.isSelected)
            return cell
        case 1:
            let cell = collectionView.dequeCell(at: indexPath) as AddMediaCollectionViewCell
            cell.setupAsPhoto()
            cell.infoLabel.text = String(self.photosToSend)
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
        switch indexPath.section {
        case 0:
            setupLargeImage(withUrl: self.urls[indexPath.row])

            let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell
            setup(imageCell: cell, asSelected: true)

            self.onSelectPhotoForPreview?(indexPath.row)
        case 1:
            self.onPressAddPhotoButton?()
            break
        case 2:
            break
        default:
            fatalError("Unknown section at AuditTilesTableViewCell")
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell
        setup(imageCell: cell, asSelected: false)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(width: 64, height: 64)
        case 1, 2:
            return CGSize(width: 54, height: 64)
        default:
            return CGSize.zero
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        switch section {
        case 0:
            return UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 0)
        case 1, 2:
            return UIEdgeInsets(top: 0, left: 4, bottom: 20, right: 0)
        default:
            return UIEdgeInsets.zero
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch section {
        case 0:
            return 10
        default:
            return CGFloat.zero
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return indexPath.section <= 1
    }

    private func setup(imageCell: ImageCollectionViewCell?,
                       asSelected: Bool) {
        guard let cell = imageCell else { return }

        if asSelected {
            cell.layer.borderWidth = AppStyle.Border.photoSelection
            cell.layer.borderColor = AppStyle.Color.green.cgColor
        } else {
            cell.layer.borderWidth = AppStyle.Border.none
            cell.layer.borderColor = UIColor.clear.cgColor
        }
    }

    private func config(heightConstraint: NSLayoutConstraint?,
                        using image: UIImage,
                        cellWidth: CGFloat,
                        minRatio: CGFloat) {
        let imageRatio = image.size.width / image.size.height
        let ratio = max(minRatio, imageRatio)
        let newHeight = (ratio > 0) ? (cellWidth / ratio) : CGFloat.zero

        if let oldHeight = heightConstraint?.constant,
            abs(oldHeight - newHeight) > 1.0 {
                heightConstraint?.constant = newHeight
        }
    }

    private func applyImageRatio(_ ratio: CGFloat) {
        if ratio > CGFloat.zero {
            self.imageHeightConstraint.constant = self.frame.width / ratio
        } else {
            self.imageHeightConstraint.constant = CGFloat.zero
        }
    }
}

//
//  AuditOptionsTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 22.02.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import UIKit
import AlignedCollectionViewFlowLayout

class AuditOptionsTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionHeightConstraint: NSLayoutConstraint!

    var onNeedUpdateHeight: (() -> Void)?
    var onChangeSelection: (([Answer]) -> Void)?

    private var options = [Answer]()
    private var answer: AuditAnswer?
    private var userAnswer: AuditQuestionAnswer?

    private let tagItemHeight: CGFloat = 30
    private let tagsInteritemSpacing: CGFloat = 10
    private let tagsLineSpacing: CGFloat = 8

    override func awakeFromNib() {
        super.awakeFromNib()

        let bgColor = AppStyle.Color.custom(hex: 0xEEEEEE)
        self.backgroundColor = bgColor
        self.collectionView.backgroundColor = bgColor

        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let tagItemWidth = collectionView.frame.width / 4
            let cellSize = CGSize(width: tagItemWidth, height: tagItemHeight)
            layout.estimatedItemSize = cellSize
            layout.minimumInteritemSpacing = tagsInteritemSpacing
            layout.minimumLineSpacing = tagsLineSpacing
            layout.minimumInteritemSpacing = 10
            layout.sectionInset = UIEdgeInsets(all: 20)
        }

        if let layout = self.collectionView.collectionViewLayout as? AlignedCollectionViewFlowLayout {
            layout.horizontalAlignment = .left
            layout.verticalAlignment = .top
        }

        let cellId = TextCollectionViewCell.viewReuseIdentifier()
        self.collectionView.register(UINib(nibName: cellId, bundle: nil),
                                     forCellWithReuseIdentifier: cellId)
    }
}

extension AuditOptionsTableViewCell: AuditQuestionTableViewCellProtocol {
    func setup(with auditQuestion: AuditQuestion) {
        self.options = auditQuestion.answers ?? []
        self.userAnswer = auditQuestion.userAnswer
        self.collectionView.isUserInteractionEnabled = (auditQuestion.userAnswer?.answer == nil)

        switch auditQuestion.questionType {
        case .trueFalse:
            self.collectionView.allowsSelection = true
            self.collectionView.allowsMultipleSelection = false
        default:
            self.collectionView.allowsSelection = false
            self.collectionView.allowsMultipleSelection = false
        }

        // updating layout
        self.collectionView.reloadData()

        self.collectionView.collectionViewLayout.invalidateLayout()
        DispatchQueue.main.async { [weak self] in
            if let collectionLayout = self?.collectionView.collectionViewLayout {
                let collectionSize = collectionLayout.collectionViewContentSize
                if self?.collectionHeightConstraint.constant != collectionSize.height {
                    self?.collectionHeightConstraint.constant = collectionSize.height

                    self?.onNeedUpdateHeight?()
                }
            }
        }
    }
}

extension AuditOptionsTableViewCell: AuditAnswerTableViewCellProtocol {
    func setup(answer auditAnswer: AuditAnswer?) {
        self.answer = auditAnswer
        self.collectionView.reloadData()
    }
}

extension AuditOptionsTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.options.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TextCollectionViewCell = collectionView.dequeCell(at: indexPath)

        // Evgeniy 3 (yes, no button)
        let tagItem = self.options[indexPath.row]
        cell.textLabel.text = tagItem.answer
        cell.textLabel.font = AppStyle.Font.regular(14)
        cell.textLabel.textColor = AppStyle.Color.textSelected.withAlphaComponent(0.87)
        cell.textLabel.textAlignment = .center

        cell.container.layer.cornerRadius = AppStyle.CornerRadius.tag
        cell.container.layer.masksToBounds = true

        var shouldSelect = false
        if let answerId = self.userAnswer?.answer {
            shouldSelect = (answerId == tagItem.identifier)
        } else {
            shouldSelect = (self.answer?.answer == tagItem.identifier)
        }

        if shouldSelect {
            collectionView.selectItem(at: indexPath,
                                      animated: false,
                                      scrollPosition: .centeredVertically)
            cell.isSelected = true
            setup(tagCell: cell, asSelected: true)
        } else {
            collectionView.deselectItem(at: indexPath, animated: true)
            cell.isSelected = false
            setup(tagCell: cell, asSelected: false)
        }


        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? TextCollectionViewCell
        setup(tagCell: cell, asSelected: true)
        handleSelectionChange(for: collectionView)
    }

    func collectionView(_ collectionView: UICollectionView,
                        didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? TextCollectionViewCell
        setup(tagCell: cell, asSelected: false)
        handleSelectionChange(for: collectionView)
    }

    private func setup(tagCell: TextCollectionViewCell?, asSelected: Bool) {
        if asSelected {
            tagCell?.container.backgroundColor = AppStyle.Color.custom(hex: 0xDAF7D6)
            tagCell?.container.layer.borderColor = AppStyle.Color.green.cgColor
            tagCell?.container.layer.borderWidth = AppStyle.Border.selection
        } else {
            tagCell?.container.backgroundColor = AppStyle.Color.backgroundMain
            tagCell?.container.layer.borderColor = AppStyle.Color.gray.cgColor
            tagCell?.container.layer.borderWidth = AppStyle.Border.default
        }
    }

    private func handleSelectionChange(for collectionView: UICollectionView) {
        let selectedOptions = collectionView.indexPathsForSelectedItems?
            .map({ self.options[$0.row] })
        onChangeSelection?(selectedOptions ?? [])
    }
}

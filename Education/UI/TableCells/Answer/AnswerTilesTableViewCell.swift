//
//  AnswerTilesTableViewCell.swift
//  Education
//
//  Created by Andrey Medvedev on 07/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class AnswerTilesTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!

    public var onChangeState: (([String]) -> Void)? {
        didSet {
            self.onChangeState?(self.state)
        }
    }

    private var answers = [Answer]()
    private var state = [String]()
    private var isEditable = true

    override func awakeFromNib() {
        super.awakeFromNib()

        self.collectionView.backgroundColor = AppStyle.Color.backgroundMain

        let cellId = ImageTileCollectionViewCell.viewReuseIdentifier()
        let nib = UINib(nibName: cellId, bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: cellId)
    }

    public func update(withAnswers: [Answer],
                       type: OptionSelectionType,
                       isEditable: Bool,
                       predefinedState: [String]?) {
        switch type {
        case .single:
            self.collectionView.allowsMultipleSelection = false
        case .multiple:
            self.collectionView.allowsMultipleSelection = true
        }
        self.answers = withAnswers
        self.state = predefinedState ?? []
        self.collectionView.reloadData()
    }
}

extension AnswerTilesTableViewCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.answers.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageTileCollectionViewCell = collectionView.dequeCell(at: indexPath)
        cell.titleLabel.text = nil
        cell.answerContainer.alpha = AppStyle.Alpha.hidden

        let answer = self.answers[indexPath.row]
        if let urlString = answer.answer,
            let url = URL(string: urlString) {
            cell.imageView.setImage(withUrl: url,
                                    placeholder: nil)
        }

        var isTileSelected = false
        if let optionId = answer.identifier {
            isTileSelected = self.state.contains(optionId)
        }
        setupTile(cell: cell, selected: isTileSelected)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageTileCollectionViewCell else {
            return
        }

        let answer = self.answers[indexPath.row]
        applyValue(answer.identifier)
        setupTile(cell: cell, selected: true)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageTileCollectionViewCell else {
            return
        }

        let answer = self.answers[indexPath.row]
        applyValue(answer.identifier)
        setupTile(cell: cell, selected: false)
    }

    private func applyValue(_ value: String?) {
        guard let value = value else { return }

        if let index = self.state.firstIndex(of: value) {
            self.state.remove(at: index)
        } else {
            self.state.append(value)
        }
        self.onChangeState?(self.state)
    }

    private func setupTile(cell: ImageTileCollectionViewCell, selected: Bool) {
        if selected {
            cell.imageView.layer.borderColor = AppStyle.Color.green.cgColor
            cell.imageView.layer.borderWidth = AppStyle.Border.tileSelection
        } else {
            cell.imageView.layer.borderColor = UIColor.clear.cgColor
            cell.imageView.layer.borderWidth = AppStyle.Border.none
        }
    }
}

extension AnswerTilesTableViewCell: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let space = collectionView.frame.width - collectionView.collectionViewLayout.sectionInset.left - collectionView.collectionViewLayout.sectionInset.right - collectionView.collectionViewLayout.minimumInteritemSpacing
        let space = collectionView.frame.width - 20 - 20 - 16
        let side = space / 2
        return CGSize(width: side, height: side)
    }
}

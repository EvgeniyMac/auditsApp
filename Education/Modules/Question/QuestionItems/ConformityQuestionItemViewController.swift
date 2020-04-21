//
//  ConformityQuestionItemViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 20/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit
import AlignedCollectionViewFlowLayout

struct DragData {
    enum SourceGroup {
        case options
        case answers
        case unknown
    }
    let source: SourceGroup
    let index: Int
    let optionId: String
}

class ConformityQuestionItemViewController: BaseQuestionItemViewController {

    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var questionTextContainerView: UIView!
    @IBOutlet weak var questionTextLabel: UILabel!

    @IBOutlet weak var answersContainerView: UIView!
    @IBOutlet weak var answersCollectionView: UICollectionView!
    @IBOutlet weak var answersCollectionHeight: NSLayoutConstraint!

    @IBOutlet weak var optionsContainerView: UIView!
    @IBOutlet weak var optionsCollectionView: UICollectionView!
    @IBOutlet weak var optionsCollectionHeight: NSLayoutConstraint!

    private let answersHandler = AnswersConformityCollectionHandler()
    private let optionsHandler = OptionsCollectionHandler()

    private let collectionHeightMin: CGFloat = 56

    var correctAnswer = [Answer]()
    var options = [Answer]()

    // MARK: - Overridings
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureCollections()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if #available(iOS 11.0, *) {
        } else {
            //WORKAROUND: Fix for initial layout at older versions (iOS 9/10)
            reloadAnswersCollection(resetHeight: true)
            reloadOptionsCollection(resetHeight: true)
        }
    }

    override func handleItem(_ item: Questionnaire.Item) {
        super.handleItem(item)

        let answers = self.item?.question.answers ?? []
        self.correctAnswer = answers
        self.options = answers.shuffled()
    }

    override func reload() {
        super.reload()

        if let url = self.item?.question.imageUrl {
            self.imageContainerView.isHidden = false
            self.imageView.setImage(withUrl: url, placeholder: UIImage())
        } else {
            self.imageContainerView.isHidden = true
        }

        if let questionText = self.item?.question.questionText {
            self.questionTextContainerView.isHidden = false
            self.questionTextLabel.text = questionText
        } else {
            self.questionTextContainerView.isHidden = true
        }

        self.answersHandler.options = self.correctAnswer
        self.answersHandler.answers = self.item?.answer?.valueDictionary ?? [:]
        self.answersHandler.onChangeState = { [weak self] in
            self?.updateAnswersState()
        }

        self.optionsHandler.options = self.options
        self.optionsHandler.answers = self.item?.answer?.valueArray ?? []
        self.optionsHandler.onChangeState = { [weak self] in
            self?.updateOptionsState()
        }

        reloadAnswersCollection(resetHeight: true)
        reloadOptionsCollection(resetHeight: true)
    }

    // MARK: - Private
    private func configureUI() {
        self.questionTextLabel.numberOfLines = 0
        self.questionTextLabel.font = AppStyle.Font.medium(20)
        self.questionTextLabel.textColor = AppStyle.Color.textMain
    }

    private func configureCollections() {
        let tileCellId = ImageTileCollectionViewCell.viewReuseIdentifier()
        self.answersCollectionView.register(UINib(nibName: tileCellId, bundle: nil),
                                            forCellWithReuseIdentifier: tileCellId)
        self.answersCollectionView.isScrollEnabled = false
        self.answersCollectionView.delegate = self.answersHandler
        self.answersCollectionView.dataSource = self.answersHandler
        if #available(iOS 11.0, *) {
//            self.answersCollectionView.dragDelegate = self
//            self.answersCollectionView.dropDelegate = self
            self.answersHandler.dragDelegate = self
            self.answersHandler.dropDelegate = self
            self.answersCollectionView.dragInteractionEnabled = false
        }
        setupCollectionView(tilesCollectionView: self.answersCollectionView)

        let optionCellId = TextCollectionViewCell.viewReuseIdentifier()
        self.optionsCollectionView.register(UINib(nibName: optionCellId, bundle: nil),
                                            forCellWithReuseIdentifier: optionCellId)
        self.optionsCollectionView.isScrollEnabled = false
        self.optionsCollectionView.delegate = self.optionsHandler
        self.optionsCollectionView.dataSource = self.optionsHandler
        if #available(iOS 11.0, *) {
            self.optionsCollectionView.dragDelegate = self
            self.optionsCollectionView.dropDelegate = self
            self.optionsCollectionView.dragInteractionEnabled = true
        }
        setupCollectionView(textCollectionView: self.optionsCollectionView)
    }

    private func setupCollectionView(textCollectionView: UICollectionView) {
        textCollectionView.allowsMultipleSelection = true
        textCollectionView.backgroundColor = .clear

        if let layout = textCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let tagItemWidth = textCollectionView.frame.width / 3
            let cellSize = CGSize(width: tagItemWidth,
                                  height: AppStyle.Collection.Texts.itemHeight)
            layout.estimatedItemSize = cellSize
            layout.minimumInteritemSpacing = AppStyle.Collection.Texts.interitemSpacing
            layout.minimumLineSpacing = AppStyle.Collection.Texts.lineSpacing
            layout.sectionInset = AppStyle.Collection.Texts.sectionInset
        }

        if let layout = textCollectionView.collectionViewLayout as? AlignedCollectionViewFlowLayout {
            layout.horizontalAlignment = .left
            layout.verticalAlignment = .center
        }

        // WORKAROUND: a hack to decrease a drag duration
        textCollectionView.gestureRecognizers?
            .compactMap({ $0 as? UILongPressGestureRecognizer })
            .forEach({ $0.minimumPressDuration = AppStyle.Gestures.dragDuration })
    }

    private func setupCollectionView(tilesCollectionView: UICollectionView) {
        tilesCollectionView.allowsMultipleSelection = true
        tilesCollectionView.backgroundColor = .clear

        if let layout = tilesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = AppStyle.Collection.Tiles.interitemSpacing
            layout.minimumLineSpacing = AppStyle.Collection.Tiles.lineSpacing
            layout.sectionInset = AppStyle.Collection.Tiles.sectionInset
        }

        // WORKAROUND: a hack to decrease a drag duration
        tilesCollectionView.gestureRecognizers?
            .compactMap({ $0 as? UILongPressGestureRecognizer })
            .forEach({ $0.minimumPressDuration = AppStyle.Gestures.dragDuration })
    }

    private func reloadAnswersCollection(resetHeight: Bool) {
        self.answersCollectionView.performBatchUpdates({ [weak self] in
            self?.answersCollectionView.reloadSections(IndexSet(integer: 0))
        }, completion: { [weak self] (completed) in
            guard completed && resetHeight else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.updateAnswersCollectionHeight()
            }
        })
    }

    private func updateAnswersCollectionHeight() {
        let layout = self.answersCollectionView.collectionViewLayout
        let minHeight = self.collectionHeightMin
        let collectionSize = layout.collectionViewContentSize
        self.answersCollectionHeight.constant = max(collectionSize.height, minHeight)
    }

    private func reloadOptionsCollection(resetHeight: Bool) {
        self.optionsCollectionView.performBatchUpdates({ [weak self] in
            self?.optionsCollectionView.reloadSections(IndexSet(integer: 0))
        }, completion:  { [weak self] (completed) in
            guard completed && resetHeight else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.updateOptionsCollectionHeight()
            }
        })
    }

    private func updateOptionsCollectionHeight() {
        let layout = self.optionsCollectionView.collectionViewLayout
        let minHeight = self.collectionHeightMin
        let collectionSize = layout.collectionViewContentSize
        self.optionsCollectionHeight.constant = max(collectionSize.height, minHeight)
    }

    private func updateAnswersState() {
        let answersDictionary: [String: String] = self.answersHandler.answers
        let answersArray = answersDictionary.values.map({ $0 })

        self.optionsHandler.answers = answersArray
        reloadAnswersCollection(resetHeight: false)
        reloadOptionsCollection(resetHeight: false)

        let identifiersDictionary: [String: String] = self.answersHandler.answers
        let optionsCount = self.correctAnswer.count
        if answersArray.count == optionsCount,
            !answersArray.isEmpty {
            let userAnswer = Questionnaire.UserAnswer()

            var resultDictionary = [String: String]()
            for keyId in identifiersDictionary.keys {
                let keyOption = self.options.first(where: { $0.identifier == keyId })
                let valueId = identifiersDictionary[keyId]
                let valueOption = self.options.first(where: { $0.identifier == valueId })

                if let questionType = self.item?.question.type {
                    switch questionType {
                    case .conformity:
                        if let keyOptionKey = keyOption?.key {
                            resultDictionary[keyOptionKey] = valueOption?.value
                        }
                    case .conformityImage:
                        if let keyOptionId = keyOption?.identifier {
                            resultDictionary[keyOptionId] = valueOption?.value
                        }
                    default:
                        break
                    }
                }
            }
            userAnswer.valueDictionary = resultDictionary
            self.onCompletion?(userAnswer)
        } else {
            self.onCompletion?(nil)
        }
    }

    private func updateOptionsState() {
        let selectedOptionsIds: [String] = self.optionsHandler.answers
        let appliedOptions: [String] = self.answersHandler.answers.values.map({ $0 })
        let answerIds: [String] = self.answersHandler.options.compactMap({ $0.identifier })
        for optionId in selectedOptionsIds {
            guard let option = self.optionsHandler.options.first(where: {
                $0.identifier == optionId
            }) else {
                continue
            }
            guard let optionId = option.identifier,
                !appliedOptions.contains(optionId) else {
                continue
            }

            if let unmatchedId = answerIds.first(where: { identifier in
                return (self.answersHandler.answers[identifier] == nil)
            }) {
                self.answersHandler.answers[unmatchedId] = optionId
            }
        }
        self.reloadOptionsCollection(resetHeight: false)
        self.reloadAnswersCollection(resetHeight: false)

        let identifiersDictionary: [String: String] = self.answersHandler.answers
        let answersIdArray = identifiersDictionary.values.map({ $0 })
        let optionsCount = self.correctAnswer.count
        if answersIdArray.count == optionsCount,
            !answersIdArray.isEmpty {
            let userAnswer = Questionnaire.UserAnswer()

            var resultDictionary = [String: String]()
            for keyId in identifiersDictionary.keys {
                let keyOption = self.options.first(where: { $0.identifier == keyId })
                let valueId = identifiersDictionary[keyId]
                let valueOption = self.options.first(where: { $0.identifier == valueId })

                if let questionType = self.item?.question.type {
                    switch questionType {
                    case .conformity:
                        if let keyOptionKey = keyOption?.key {
                            resultDictionary[keyOptionKey] = valueOption?.value
                        }
                    case .conformityImage:
                        if let keyOptionId = keyOption?.identifier {
                            resultDictionary[keyOptionId] = valueOption?.value
                        }
                    default:
                        break
                    }
                }
            }
            userAnswer.valueDictionary = resultDictionary
            self.onCompletion?(userAnswer)
        } else {
            self.onCompletion?(nil)
        }
    }

    // MARK: - drag n drop
    func getCollectionID(for collection: UICollectionView) -> DragData.SourceGroup {
        if collection === self.answersCollectionView {
            return .answers
        } else if collection === self.optionsCollectionView {
            return .options
        }
        return .unknown
    }
}

extension ConformityQuestionItemViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        print(">>>>drag\(indexPath)")
        let collectionCell = collectionView.cellForItem(at: indexPath)
        if let cell = collectionCell as? TextCollectionViewCell {
            guard cell.state == .available else { return [] }
            guard let image = cell.container.toImage(background: .clear) else {
                return []
            }

            let provider = NSItemProvider(object: image)
            let item = UIDragItem(itemProvider: provider)
            item.localObject = image
            item.previewProvider = {
                return UIDragPreview(view: cell.container)
            }

            let option = self.options[indexPath.row]
            session.localContext = DragData(source: getCollectionID(for: collectionView),
                                            index: indexPath.row,
                                            optionId: option.identifier ?? String())
            return [item]
        } else if let cell = collectionCell as? ImageTileCollectionViewCell {
            guard cell.answerContainer.alpha != AppStyle.Alpha.hidden else { return [] }
            guard let image = cell.answerContainer.toImage(background: .clear) else {
                return []
            }

            let provider = NSItemProvider(object: image)
            let item = UIDragItem(itemProvider: provider)
            item.localObject = image
            item.previewProvider = {
                return UIDragPreview(view: cell.answerContainer)
            }

            let option = self.options[indexPath.row]
            session.localContext = DragData(source: getCollectionID(for: collectionView),
                                            index: indexPath.row,
                                            optionId: option.identifier ?? String())
            return [item]
        }

        return []
    }

    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView,
                        performDropWith coordinator: UICollectionViewDropCoordinator) {
        print("<<<<drop\(String(describing: coordinator.destinationIndexPath))")
        let dragData = coordinator.session.localDragSession?.localContext as? DragData
        guard let index = dragData?.index else {
            return
        }

        if collectionView === self.answersCollectionView {
            // item goes to answers
            if dragData?.source == getCollectionID(for: collectionView) {
                // item goes from answers
                guard let optionIdFrom = self.correctAnswer[index].identifier,
                    let optionId = self.answersHandler.answers[optionIdFrom] else {
                        return
                }

                self.answersHandler.answers[optionIdFrom] = nil
                self.optionsHandler.answers.removeAll(where: { $0 == optionIdFrom })
                if let indexPath = coordinator.destinationIndexPath,
                    let answerIdTo = self.correctAnswer[indexPath.item].identifier {

                    if let optionIdTo = self.answersHandler.answers[answerIdTo] {
                        // moving value from drop position to drag position if needed
                        self.answersHandler.answers[optionIdFrom] = optionIdTo
                        self.optionsHandler.answers.append(optionIdTo)
                    }

                    self.answersHandler.answers[answerIdTo] = optionId
                    self.optionsHandler.answers.append(optionId)
                } else {
                    let identifiers = self.correctAnswer.compactMap({ $0.identifier })
                    if let firstAvailableId = identifiers.first(where: {
                        self.answersHandler.answers[$0] == nil
                    }) {
                        self.answersHandler.answers[firstAvailableId] = optionId
                        self.optionsHandler.answers.append(optionId)
                    }
                }
//                reloadAnswersCollection(resetHeight: true)
            } else {
                // item goes from options
                guard let optionId = self.optionsHandler.options[index].identifier else { return }

                if let indexPath = coordinator.destinationIndexPath,
                    let answerIdTo = self.correctAnswer[indexPath.item].identifier {
                    self.answersHandler.answers[answerIdTo] = optionId
                    self.optionsHandler.answers.append(optionId)
                } else {
                    let identifiers = self.correctAnswer.compactMap({ $0.identifier })
                    if let firstAvailableId = identifiers.first(where: {
                        self.answersHandler.answers[$0] == nil
                    }) {
                        self.answersHandler.answers[firstAvailableId] = optionId
                        self.optionsHandler.answers.append(optionId)
                    }
                }
//                reloadAnswersCollection(resetHeight: true)
//                reloadOptionsCollection(resetHeight: false)
            }

            updateAnswersState()
        } else if collectionView === self.optionsCollectionView {
            // item goes to options
            if dragData?.source == getCollectionID(for: collectionView) {
                // item goes from options
                // doing nothing
            } else {
                // item goes from answers
                if let optionIdFrom = self.correctAnswer[index].identifier,
                    let optionId = self.answersHandler.answers[optionIdFrom] {
                        self.answersHandler.answers[optionIdFrom] = nil
                        self.optionsHandler.answers.removeAll(where: { $0 == optionId })
                }

//                reloadAnswersCollection(resetHeight: true)
//                reloadOptionsCollection(resetHeight: false)
            }

            updateOptionsState()
        }

        print("ADDED")

//        reloadAnswersCollection(resetHeight: true)
//        reloadOptionsCollection(resetHeight: false)


//        if let indexPath = coordinator.destinationIndexPath {
//            self.answers.insert(optionId, at: indexPath.item)
//        } else {
//            self.answers.append(optionId)
//        }
//        self.onChangeState?()
    }

    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView,
                        dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        print("collectionView:dropSessionDidUpdate destinationIndexPath=\(destinationIndexPath)")

        let dragCollectionData = session.localDragSession?.localContext as? DragData
        var operation = UIDropOperation.move
//        if dragCollectionData?["id"] != getCollectionID(for: collectionView) {
//            operation = UIDropOperation.copy
//            print("COPY")
//        } else {
//            print("MOVE")
//        }

        return UICollectionViewDropProposal(operation: operation, intent: UICollectionViewDropProposal.Intent.insertIntoDestinationIndexPath)
    }

//    @available(iOS 11.0, *)
//    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
//        print("collectionView:itemsForAddingTo indexPath=\(indexPath) point=\(point)")
//    }

    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView,
                        dropSessionDidEnd session: UIDropSession) {
        print("dropSessionDidEnd")

        if collectionView === self.answersCollectionView {
//            if let indexPath = session.dest.destinationIndexPath {
//                self.answersHandler.answers.insert(optionId, at: indexPath.item)
//            } else {
//                self.answersHandler.answers.append(optionId)
//            }
//            reloadAnswersCollection(resetHeight: true)
//            reloadOptionsCollection(resetHeight: true)
        } else if collectionView === self.optionsCollectionView {

        }
    }

    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView,
                        dragSessionAllowsMoveOperation session: UIDragSession) -> Bool {
        let allowMoving = (collectionView === self.answersCollectionView)
        print("allowMoving:\(allowMoving)")
        return true//allowMoving
    }
}

extension ConformityQuestionItemViewController: UIDragInteractionDelegate, UIDropInteractionDelegate {
    @available(iOS 11.0, *)
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return true
    }

    @available(iOS 11.0, *)
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .move)
    }

    @available(iOS 11.0, *)
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        print("!!!performDrop!")
        let dragData = session.localDragSession?.localContext as? DragData

            if let cell = interaction.view as? ImageTileCollectionViewCell {
            // drop to answers
            if dragData?.source == DragData.SourceGroup.options {
                // dragging from options
                guard let optionId = dragData?.optionId else {
                    return
                }
                if let indexPath = self.answersCollectionView.indexPath(for: cell),
                    let answerIdTo = self.correctAnswer[indexPath.item].identifier {
                        self.answersHandler.answers[answerIdTo] = optionId
//                        self.optionsHandler.answers.insert(optionId, at: indexPath.item)
                        self.optionsHandler.answers.append(optionId)
                } else {
                    let identifiers = self.correctAnswer.compactMap({ $0.identifier })
                    if let firstAvailableId = identifiers.first(where: {
                        self.answersHandler.answers[$0] == nil
                    }) {
                        self.answersHandler.answers[firstAvailableId] = optionId
                        self.optionsHandler.answers.append(optionId)
                    }
                }

                updateAnswersState()
            } else {
                // dragging from answers
                guard let index = dragData?.index,
                    let optionIdFrom = self.correctAnswer[index].identifier,
                    let optionId = self.answersHandler.answers[optionIdFrom] else {
                        return
                }

                if let indexPath = self.answersCollectionView.indexPath(for: cell),
                    let answerIdTo = self.correctAnswer[indexPath.item].identifier {

                    if let optionIdTo = self.answersHandler.answers[answerIdTo] {
                        self.answersHandler.answers[optionIdFrom] = optionIdTo
                        self.optionsHandler.answers.append(optionIdTo)
                    } else {
                        self.answersHandler.answers[optionIdFrom] = nil
                        self.optionsHandler.answers.removeAll(where: { $0 == optionIdFrom })
                    }
                    self.answersHandler.answers[answerIdTo] = optionId
                    self.optionsHandler.answers.append(optionId)
                }
            }

            updateAnswersState()
        }
    }

    @available(iOS 11.0, *)
    func dragInteraction(_ interaction: UIDragInteraction, sessionForAddingItems sessions: [UIDragSession], withTouchAt point: CGPoint) -> UIDragSession? {
        print("~~~~~~~~~~~sessionForAddingItems: \(sessions.count)")
        return sessions.first
    }

    @available(iOS 11.0, *)
    func dragInteraction(_ interaction: UIDragInteraction,
                         itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        print(">>>>drag\(interaction.view)")

        if let answerContainer = interaction.view {
            guard answerContainer.alpha != AppStyle.Alpha.hidden else {
                return []
            }
            guard let image = answerContainer.toImage(background: .clear) else {
                return []
            }

            let provider = NSItemProvider(object: image)
            let item = UIDragItem(itemProvider: provider)
            item.localObject = image
            item.previewProvider = {
                return UIDragPreview(view: answerContainer)
            }

            let index = answerContainer.tag
            let option = self.options[index]
            session.localContext = DragData(source: .answers,
                                            index: index,
                                            optionId: option.identifier ?? String())
            return [item]
        }

        return []
    }

//    func dragInteraction(_ interaction: UIDragInteraction, session: UIDragSession, didEndWith operation: UIDropOperation) {
//        operation.
//    }
}

class AnswersConformityCollectionHandler: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    weak var dragDelegate: NSObject? //UIDragInteractionDelegate?
    weak var dropDelegate: NSObject? //UIDropInteractionDelegate?

    var options = [Answer]()
    var answers = [String: String]()
    var onChangeState: (() -> Void)?

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.options.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageTileCollectionViewCell = collectionView.dequeCell(at: indexPath)

        let option = self.options[indexPath.row]

        cell.imageView.image = nil
        cell.titleLabel.text = nil
        if let answerString = option.answer,
            let imageUrl = URL(string: answerString) {
            cell.imageView.af_setImage(withURL: imageUrl)
        } else {
            cell.titleLabel.text = option.key
        }

        if let optionId = option.identifier,
            let answerId = self.answers[optionId],
            let answer = self.options.first(where: { $0.identifier == answerId }) {
            cell.answerLabel.text = answer.value
            cell.answerContainer.alpha = AppStyle.Alpha.default
        } else {
            cell.answerContainer.alpha = AppStyle.Alpha.hidden
        }

        if #available(iOS 11.0, *) {
            cell.answerContainer.tag = indexPath.row
            if let dragDelegate = self.dragDelegate as? UIDragInteractionDelegate {
                for interaction in cell.answerContainer.interactions {
                    cell.answerContainer.removeInteraction(interaction)
                }

                let interaction = UIDragInteraction(delegate: dragDelegate)
                interaction.isEnabled = true
                cell.answerContainer.addInteraction(interaction)
            }
            if let dropDelegate = self.dropDelegate as? UIDropInteractionDelegate  {
                for interaction in cell.interactions {
                    cell.removeInteraction(interaction)
                }
                cell.addInteraction(UIDropInteraction(delegate: dropDelegate))
            }
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let option = self.options[indexPath.row]
        if let optionId = option.identifier {
            self.answers[optionId] = nil
        }
        self.onChangeState?()
    }

    func collectionView(_ collectionView: UICollectionView,
                        shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let space = collectionView.frame.width -
            AppStyle.Collection.Tiles.sectionInset.left -
            AppStyle.Collection.Tiles.sectionInset.right -
            AppStyle.Collection.Tiles.interitemSpacing
        let side = space / 2
        return CGSize(width: side, height: side)
    }
}

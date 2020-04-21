//
//  SequenceQuestionItemViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 15/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit
import AlignedCollectionViewFlowLayout

class SequenceQuestionItemViewController: BaseQuestionItemViewController {

    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var questionTextContainerView: UIView!
    @IBOutlet weak var questionTextLabel: UILabel!

    @IBOutlet weak var answersContainerView: UIView!
    @IBOutlet weak var answersCollectionView: UICollectionView!
    @IBOutlet weak var answersCollectionHeight: NSLayoutConstraint!

    @IBOutlet weak var separatorView: UIView!

    @IBOutlet weak var optionsContainerView: UIView!
    @IBOutlet weak var optionsCollectionView: UICollectionView!
    @IBOutlet weak var optionsCollectionHeight: NSLayoutConstraint!

    private let answersHandler = AnswersSequenceCollectionHandler()
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

        self.answersHandler.options = self.options
        self.answersHandler.answers = self.item?.answer?.valueArray ?? []
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
        self.separatorView.backgroundColor = AppStyle.Color.separator

        self.questionTextLabel.numberOfLines = 0
        self.questionTextLabel.font = AppStyle.Font.medium(20)
        self.questionTextLabel.textColor = AppStyle.Color.textMain
    }

    private func configureCollections() {
        let answerCellId = TextCollectionViewCell.viewReuseIdentifier()
        self.answersCollectionView.register(UINib(nibName: answerCellId, bundle: nil),
                                            forCellWithReuseIdentifier: answerCellId)
        self.answersCollectionView.isScrollEnabled = false
        self.answersCollectionView.delegate = self.answersHandler
        self.answersCollectionView.dataSource = self.answersHandler
        if #available(iOS 11.0, *) {
            self.answersCollectionView.dragDelegate = self
            self.answersCollectionView.dropDelegate = self
            self.answersCollectionView.dragInteractionEnabled = true
        }
        setupCollectionView(textCollectionView: self.answersCollectionView)

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

    private func reloadAnswersCollection(resetHeight: Bool) {
        self.answersCollectionView.performBatchUpdates({ [weak self] in
            self?.answersCollectionView.reloadSections(IndexSet(integer: 0))
        }, completion:  { [weak self] (completed) in
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

    private func updateOptionsState() {
        let answersArray = self.optionsHandler.answers
        self.answersHandler.answers = answersArray
        reloadAnswersCollection(resetHeight: true)
        reloadOptionsCollection(resetHeight: false)

        let optionsCount = self.correctAnswer.count
        if answersArray.count == optionsCount,
            !answersArray.isEmpty {
            let userAnswer = Questionnaire.UserAnswer()
            let resultArray = answersArray.compactMap({ (answerId) in
                return self.correctAnswer
                    .first(where: { $0.identifier == answerId })?.value
            })
            userAnswer.valueArray = resultArray
            self.onCompletion?(userAnswer)
        } else {
            self.onCompletion?(nil)
        }
    }

    private func updateAnswersState() {
        let answersArray = self.answersHandler.answers
        self.optionsHandler.answers = answersArray
        reloadAnswersCollection(resetHeight: true)
        reloadOptionsCollection(resetHeight: false)

        let optionsCount = self.correctAnswer.count
        if answersArray.count == optionsCount,
            !answersArray.isEmpty {
            let userAnswer = Questionnaire.UserAnswer()

            let resultArray = answersArray.compactMap({ (answerId) in
                return self.correctAnswer
                    .first(where: { $0.identifier == answerId })?.value
            })
            userAnswer.valueArray = resultArray
            self.onCompletion?(userAnswer)
        } else {
            self.onCompletion?(nil)
        }
    }

    // MARK: - drag n drop
    var fromIndexPath: IndexPath?

    func getCollectionID(for collection: UICollectionView) -> String? {
        if collection === self.answersCollectionView {
            return "answers"
        } else if collection === self.optionsCollectionView {
            return "options"
        }
        return nil
    }
}

extension SequenceQuestionItemViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        print(">>>>drag\(indexPath)")
        guard let cell = collectionView.cellForItem(at: indexPath) as? TextCollectionViewCell,
            let image = cell.container.toImage(background: .clear) else {
                return []
        }

        guard cell.state == .available else { return [] }

        let provider = NSItemProvider(object: image)
        let item = UIDragItem(itemProvider: provider)
        item.localObject = image
        item.previewProvider = {
            return UIDragPreview(view: cell.container)
        }
        self.fromIndexPath = indexPath

        var info = [String: String]()
        info["id"] = getCollectionID(for: collectionView)
        session.localContext = info

        return [item]
    }

    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView,
                        performDropWith coordinator: UICollectionViewDropCoordinator) {
        print("<<<<drop\(coordinator.destinationIndexPath)")
        guard let index = self.fromIndexPath?.item  else {
            return
        }

        let dragData = coordinator.session.localDragSession?.localContext as? [String:String]
        let dragCollectionId = dragData?["id"]
        if collectionView === self.answersCollectionView {
            // item goes to answers
            if dragCollectionId == getCollectionID(for: collectionView) {
                // item goes from answers
                let optionId = self.answersHandler.answers[index]

                self.answersHandler.answers.removeAll(where: { $0 == optionId })
                self.optionsHandler.answers.removeAll(where: { $0 == optionId })
                if let indexPath = coordinator.destinationIndexPath {
                    self.answersHandler.answers.insert(optionId, at: indexPath.item)
                    self.optionsHandler.answers.insert(optionId, at: indexPath.item)
                } else {
                    self.answersHandler.answers.append(optionId)
                    self.optionsHandler.answers.append(optionId)
                }
//                reloadAnswersCollection(resetHeight: true)
            } else {
                // item goes from options
                guard let optionId = self.optionsHandler.options[index].identifier else { return }

                if let indexPath = coordinator.destinationIndexPath {
                    self.answersHandler.answers.insert(optionId, at: indexPath.item)
                    self.optionsHandler.answers.insert(optionId, at: indexPath.item)
                } else {
                    self.answersHandler.answers.append(optionId)
                    self.optionsHandler.answers.append(optionId)
                }
//                reloadAnswersCollection(resetHeight: true)
//                reloadOptionsCollection(resetHeight: false)
            }

            updateAnswersState()
        } else if collectionView === self.optionsCollectionView {
            // item goes to options
            if dragCollectionId == getCollectionID(for: collectionView) {
                // item goes from options
                // doing nothing
            } else {
                // item goes from answers
                let optionId = self.answersHandler.answers[index]

                self.answersHandler.answers.removeAll(where: { $0 == optionId })
                self.optionsHandler.answers.removeAll(where: { $0 == optionId })

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

        let dragCollectionData = session.localDragSession?.localContext as? [String: String]
        var operation = UIDropOperation.move
//        if dragCollectionData?["id"] != getCollectionID(for: collectionView) {
//            operation = UIDropOperation.copy
//            print("COPY")
//        } else {
//            print("MOVE")
//        }

        return UICollectionViewDropProposal(operation: operation, intent: UICollectionViewDropProposal.Intent.insertAtDestinationIndexPath)
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

class AnswersSequenceCollectionHandler: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {

    var options = [Answer]()
    var answers = [String]()
    var onChangeState: (() -> Void)?

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.answers.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TextCollectionViewCell = collectionView.dequeCell(at: indexPath)
        let optionId = self.answers[indexPath.row]
        let option = self.options.first(where: { $0.identifier == optionId })
        cell.textLabel.text = option?.value
        cell.state = .available
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        self.answers.remove(at: indexPath.row)
        self.onChangeState?()
    }

    func collectionView(_ collectionView: UICollectionView,
                        shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

class OptionsCollectionHandler: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {

    var options = [Answer]()
    var answers = [String]()
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
        let cell: TextCollectionViewCell = collectionView.dequeCell(at: indexPath)

        // TODO: disable vertical fitting for cells
//        cell.fitToTextVertically = false

        let option = self.options[indexPath.row]
        cell.textLabel.text = option.value

        if let optionId = option.identifier,
            answers.contains(optionId) {
            cell.state = .selected
        } else {
            cell.state = .available
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView
            .cellForItem(at: indexPath) as? TextCollectionViewCell else {
            return
        }
        guard cell.state == .available else { return }

        cell.state = .selected

        let option = self.options[indexPath.row]
        if let optionId = option.identifier {
            self.answers.append(optionId)
        }
        self.onChangeState?()
    }

    func collectionView(_ collectionView: UICollectionView,
                        shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

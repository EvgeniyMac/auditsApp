//
//  WalkthroughViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 27/09/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class WalkthroughViewController: BaseViewController {

    private struct WalkthroughItem {
        let imageName: String
        let titleKey: String
        let subtitleKey: String
    }

    private let dataSource: [WalkthroughItem] = {
        return [WalkthroughItem(imageName: "walkthrough_7skills",
                                titleKey: "walkthrough.7skills.title",
                                subtitleKey: "walkthrough.7skills.subtitle"),
                WalkthroughItem(imageName: "walkthrough_chat",
                                titleKey: "walkthrough.chat.title",
                                subtitleKey: "walkthrough.chat.subtitle"),
                WalkthroughItem(imageName: "walkthrough_library",
                                titleKey: "walkthrough.library.title",
                                subtitleKey: "walkthrough.library.subtitle"),
                WalkthroughItem(imageName: "walkthrough_audit",
                                titleKey: "walkthrough.audit.title",
                                subtitleKey: "walkthrough.audit.subtitle"),
                WalkthroughItem(imageName: "walkthrough_education",
                                titleKey: "walkthrough.education.title",
                                subtitleKey: "walkthrough.education.subtitle"),
                WalkthroughItem(imageName: "walkthrough_todo",
                                titleKey: "walkthrough.todo.title",
                                subtitleKey: "walkthrough.todo.subtitle")]
    }()

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var proceedButton: UIButton!

    private var shouldTrackPages = true

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureCollectionView()
    }

    // MARK: - Actions
    @IBAction func didPressProceedButton(_ sender: Any) {
        let isLast = (self.pageControl.currentPage == self.dataSource.count - 1)
        if isLast {
            NavigationManager.shared.setup()
        } else {
            scrollToNextPage()
        }
    }

    // MARK: - Private
    private func configureUI() {
        let buttonTitle = Localization.string("walkthrough.button_start.title")
        self.proceedButton.setTitle(buttonTitle, for: .normal)
        self.proceedButton.backgroundColor = AppStyle.Color.main
        self.proceedButton.titleLabel?.font = AppStyle.Font.bold(14)
        self.proceedButton.setTitleColor(AppStyle.Color.white, for: .normal)
        self.proceedButton.layer.cornerRadius = AppStyle.CornerRadius.button
        self.proceedButton.layer.masksToBounds = true

        self.pageControl.pageIndicatorTintColor = AppStyle.Color.tintUnselected
        self.pageControl.currentPageIndicatorTintColor = AppStyle.Color.main
        self.pageControl.numberOfPages = self.dataSource.count
        self.pageControl.isUserInteractionEnabled = false
    }

    private func configureCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false

        let cellId = WalkthroughCollectionViewCell.viewReuseIdentifier()
        let cellNib = UINib(nibName: cellId, bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: cellId)
    }

    private func configureProceedButton() {
        let isLast = (self.pageControl.currentPage == self.dataSource.count - 1)
        configureProceedButton(isLastPage: isLast)
    }

    private func configureProceedButton(isLastPage: Bool) {
        var buttonTitle: String
        if isLastPage {
            buttonTitle = Localization.string("walkthrough.button_start.title")
        } else {
            buttonTitle = Localization.string("walkthrough.button_proceed.title")
        }
        self.proceedButton.setTitle(buttonTitle, for: .normal)
    }

    private func scrollToNextPage() {
        let nextIndex = self.pageControl.currentPage + 1
        guard nextIndex < self.collectionView.numberOfItems(inSection: 0) else {
            NavigationManager.shared.setup()
            return
        }

        self.collectionView.scrollToItem(at: IndexPath(item: nextIndex, section: 0),
                                         at: .centeredHorizontally,
                                         animated: true)
    }

}

extension WalkthroughViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if self.shouldTrackPages {
            self.pageControl.currentPage = indexPath.item
            configureProceedButton()
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: WalkthroughCollectionViewCell = collectionView.dequeCell(at: indexPath)
        let item = self.dataSource[indexPath.item]
        cell.imageView.image = UIImage(named: item.imageName)
        cell.titleLabel.text = Localization.string(item.titleKey)
        cell.subtitleLabel.text = Localization.string(item.subtitleKey)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.shouldTrackPages = true
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.shouldTrackPages = false
        updateSelectedPage()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.shouldTrackPages = true
        updateSelectedPage()
    }

    private func updateSelectedPage() {
        let visibleIndexPaths = self.collectionView.indexPathsForVisibleItems
        if let indexPath = visibleIndexPaths.first,
            visibleIndexPaths.count == 1 {
            let index = indexPath.item
            self.pageControl.currentPage = index
            configureProceedButton()
        }
    }
}

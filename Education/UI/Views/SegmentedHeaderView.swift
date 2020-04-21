//
//  SegmentedHeaderView.swift
//  Education
//
//  Created by Andrey Medvedev on 23/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit
import HMSegmentedControl

class SegmentedHeaderView: UIView {

    private let kBottomLineHeight: CGFloat = 2.0

    private weak var segmentedControl: HMSegmentedControl?
    private var selectionHandler: ((Int) -> Void)?
    private var insetConstraints = [NSLayoutConstraint]()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        configureSeparator()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
//        configureSeparator()
    }

    func resetInsets(_ insets: UIEdgeInsets) {
        guard let control = self.segmentedControl else { return }

        self.removeConstraints(self.insetConstraints)
        self.insetConstraints.removeAll()

        let constraints = self.createContiguousConstraints(toView: control,
                                                           insets: insets)
        self.addConstraints(constraints)
        self.insetConstraints.append(contentsOf: constraints)
    }

    func setupSegments(withTitles titles: [String],
                       selectedIndex: Int,
                       handler: ((Int) -> Void)?) {
        guard let control = HMSegmentedControl(sectionTitles: titles) else {
            return
        }

        control.addTarget(self, action: #selector(didChangeSegment(control:)), for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(control)
        self.segmentedControl = control

        resetInsets(UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20))
        configureSegmentedControl(control)

//        self.segmentedControl.sectionTitles.removeAll()
        self.selectionHandler = handler

//        titles.enumerated().forEach { (offset, element) in
//            segmentedControl.sectionTitles.append(element)
//            segmentedControl.insertSegment(withTitle: element, at: offset, animated: false)
//        }

        let index = (selectedIndex < titles.count) ? selectedIndex : 0
        self.segmentedControl?.selectedSegmentIndex = index
    }

    func selectSegment(atIndex: Int) {
        self.segmentedControl?.setSelectedSegmentIndex(UInt(atIndex), animated: true)
    }

    // MARK: - Actions
    @objc private func didChangeSegment(control: UISegmentedControl) {
        self.selectionHandler?(control.selectedSegmentIndex)
    }

    // MARK: - Private
    private func configureSegmentedControl(_ control: HMSegmentedControl) {
        control.borderType = .bottom
        control.borderColor = AppStyle.Color.lightGray
        control.selectionStyle = .textWidthStripe
        control.selectionIndicatorHeight = kBottomLineHeight
        let insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 20)
        control.selectionIndicatorEdgeInsets = insets
        control.selectionIndicatorLocation = .down
        control.selectionIndicatorColor = AppStyle.Color.main

        // Evgeniy 1
        control.titleTextAttributes = AppStyle.Text.segmentDetailDefault
        control.selectedTitleTextAttributes = AppStyle.Text.segmentSelected
    }

    private func configureSeparator() {
        let separatorView = UIView(frame: .zero)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = AppStyle.Color.lightGray
        self.addSubview(separatorView)

        let constraints = [
            createContiguousConstraint(toItem: separatorView, attribute: .leading),
            createContiguousConstraint(toItem: separatorView, attribute: .trailing),
            createContiguousConstraint(toItem: separatorView, attribute: .bottom)
        ]
        self.addConstraints(constraints)

        separatorView.addSizeConstraints(width: nil,
                                         height: kBottomLineHeight)
    }
}

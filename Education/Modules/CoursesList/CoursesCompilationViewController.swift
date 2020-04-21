//
//  CoursesCompilationViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 25/05/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class CoursesCompilationViewController: BaseViewController {

    enum CoursesCompilationType {
        case random
        case recommended
    }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!

    private var courses = [Course]()

    // TODO: change initialization of this parameter
    public var coursesType = CoursesCompilationType.random
    public var onSelectCourse: ((Course) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTitleLabel()
        setupCollectionView()
    }

    override func localizeUI() {
        super.localizeUI()

        setupTitleLabel()
        self.collectionView.reloadData()
    }

    public func loadCourses(completion: (([Course]) -> Void)?) {
        let successHandlerRandom: (([Course]) -> Void) = { [weak self] items in
            self?.courses = items
            self?.collectionView.reloadData()
            completion?(items)
        }
        let successHandler: ((CoursesListPage) -> Void) = { [weak self] data in
            self?.courses = data.courses
            self?.collectionView.reloadData()
            completion?(data.courses)
        }
        let failureHandler: ((NetworkError) -> Void) = { [weak self] error in
            self?.courses = []
            self?.collectionView.reloadData()
            completion?([])
        }

        switch self.coursesType {
        case .random:
            CoursesService.loadRandomCourses(success: successHandlerRandom,
                                             failure: failureHandler)
        case .recommended:
            CoursesService.loadRecommendedCourses(success: successHandler,
                                                  failure: failureHandler)
        }
    }

    // MARK: - Private
    private func setupCollectionView() {
        let cellId = CourseCollectionViewCell.viewReuseIdentifier()
        self.collectionView.register(UINib(nibName: cellId, bundle: nil),
                                     forCellWithReuseIdentifier: cellId)

        self.collectionView.delegate = self
        self.view.addSubview(self.collectionView)
        let constraints = self.view.createContiguousConstraints(toView: self.collectionView)
        self.view.addConstraints(constraints)
    }

    private func setupTitleLabel() {
        self.titleLabel.font = AppStyle.Font.medium(18)
        self.titleLabel.textColor = AppStyle.Color.textMain
        switch self.coursesType {
        case .random:
            self.view.backgroundColor = AppStyle.Color.backgroundMain
            self.titleLabel.text = Localization.string("courses_compilation.title_random")
        case .recommended:
            self.view.backgroundColor = AppStyle.Color.backgroundSecondary
            self.titleLabel.text = Localization.string("courses_compilation.title_recommended")
        }}
}

extension CoursesCompilationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.courses.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        let course = self.courses[indexPath.row]
        self.onSelectCourse?(course)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellId = CourseCollectionViewCell.viewReuseIdentifier()
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId,
                                                            for: indexPath) as? CourseCollectionViewCell else {
            fatalError("Unable to load CourseCollectionViewCell")
        }

        let course = self.courses[indexPath.row]
        apply(to: cell, course: course)
        cell.titleLabel.numberOfLines = 3
        return cell
    }

    private func apply(to cell: CourseCollectionViewCell, course: Course?) {
        cell.titleLabel.text = course?.name

        if let coverUrl = course?.coverUrl {
            cell.logoImageView.setImage(withUrl: coverUrl, placeholder: UIImage(named: "course_placeholder"))
        } else {
            cell.logoImageView.image = UIImage(named: "course_placeholder")
        }

        if let timeoutInt = course?.timeout,
            let timeoutDouble = Double(exactly: timeoutInt) {
            let measure = Localization.string("common.minutes_short")
            cell.durationLabel.text = String(format: "%d \(measure)", Int(ceil(timeoutDouble / 60.0)))
        } else {
            cell.durationLabel.text = nil
        }

        cell.complexityLabel.text = CourseDisplayHelper.getComplexityText(for: course)
        cell.complexityImageView.image = CourseDisplayHelper.getComplexityImage(for: course)

        if let rate = course?.rate {
            cell.rateLabel.text = String(format: "%.1f", rate)
        } else {
            cell.rateLabel.text = nil
            cell.rateImageView.image = nil
        }

        if let passedUsersCount = course?.stats?.passedUsersCount {
            cell.passedUsersLabel.text = String(passedUsersCount)
        } else {
            cell.passedUsersLabel.text = nil
            cell.passedUsersImageView.image = nil
        }

        // temporarily solution to display only duration
        // TODO: remove this code if design would change
        cell.rateImageView.isHidden = true
        cell.rateLabel.isHidden = true
        cell.passedUsersImageView.isHidden = true
        cell.passedUsersLabel.isHidden = true
    }
}

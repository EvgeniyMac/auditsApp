//
//  CourseInfoViewController+UITableViewDelegate.swift
//  Education
//
//  Created by Andrey Medvedev on 19/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

extension CourseInfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 1,
            self.viewModel?.selectedCourseInfoType == .content {
            if let rows = self.viewModel?.contentRows,
                rows.count > indexPath.row {
                switch rows[indexPath.row] {
                case .material(let course, let material):
                    guard material.isActive == true else { return }

                    if let docType = material.documentType {
                        switch docType {
                        case .test, .exam:
                            self.output.openQuestions(for: material, from: course)
                        case .chapter:
                            self.output.openMaterial(material, from: course)
                        }
                    } else {
                        self.output.openMaterial(material, from: course)
                    }
                default:
                    break
                }
            }
        }
    }
}

extension CourseInfoViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let vm = self.viewModel else { return 0 }

        switch section {
        case 0:
            return vm.courseRows.count
        case 1:
            switch vm.selectedCourseInfoType {
            case .content:
                return vm.contentRows.count
            case .about:
                return vm.aboutRows.count
            case .reviews:
                return vm.reviewsRows.count
            }
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            return self.segmentedHeader
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return AppStyle.Table.segmentedHeaderHeight
        }
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let vm = self.viewModel else { return UITableViewCell() }

        switch indexPath.section {
        case 0:
            return createCell(tableView: tableView,
                              indexPath: indexPath,
                              row: self.viewModel?.courseRows[indexPath.row])
        case 1:
            switch vm.selectedCourseInfoType {
            case .content:
                return createCell(tableView: tableView,
                                  indexPath: indexPath,
                                  row: self.viewModel?.contentRows[indexPath.row])
            case .about:
                return createCell(tableView: tableView,
                                  indexPath: indexPath,
                                  row: self.viewModel?.aboutRows[indexPath.row])
            case .reviews:
                return createCell(tableView: tableView,
                                  indexPath: indexPath,
                                  row: self.viewModel?.reviewsRows[indexPath.row])
            }
        default:
            return UITableViewCell()
        }
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let appearingLabel = self.navigationItem.titleView as? AppearingNavigationLabel {
            appearingLabel.updateTitleView(value: scrollView.contentOffset.y)
        }
    }

    // MARK: - Actions

    // MARK: - Private
    private func createCell(tableView: UITableView,
                            indexPath: IndexPath,
                            row: CourseInfoViewModel.CourseInfoTableRow?) -> UITableViewCell {
        guard let row = row else {
            fatalError("Unable to create a cell for unknown row")
        }

        switch row {
        case .info(let course):
            return createCourseInfoCell(tableView: tableView,
                                        indexPath: indexPath,
                                        course: course)
        case .stats(let course):
            return createCourseStatsCell(tableView: tableView,
                                         indexPath: indexPath,
                                         course: course)
        case .button(let course):
            return createDoubleButtonCell(tableView: tableView,
                                          indexPath: indexPath,
                                          course: course)
        case .material(let course, let material):
            return createMaterialCell(tableView: tableView,
                                      indexPath: indexPath,
                                      course: course,
                                      material: material)
        case .text(let text):
            return createAboutCell(tableView: tableView,
                                   indexPath: indexPath,
                                   text: text)
        case .title(let text, let insetTop, let insetBottom):
            let insets = UIEdgeInsets(top: CGFloat(insetTop),
                                      left: 20,
                                      bottom: CGFloat(insetBottom),
                                      right: 20)
            return createTitleCell(tableView: tableView,
                                   indexPath: indexPath,
                                   insets: insets,
                                   text: text)
        case .tags(let tags):
            return createTagsCell(tableView: tableView,
                                  indexPath: indexPath,
                                  tags: tags)
        case .rewards:
            return createRewardsCell(tableView: tableView,
                                     indexPath: indexPath)
        }
    }

    private func createCourseInfoCell(tableView: UITableView,
                                        indexPath: IndexPath,
                                        course: Course?) -> CourseInfoTableViewCell {
        let cell: CourseInfoTableViewCell = tableView.dequeCell(at: indexPath)
        TableCellStyle.apply(to: cell, course: course)
        cell.selectionStyle = .none
        cell.backgroundColor = AppStyle.Color.backgroundSecondary
        return cell
    }

    private func createCourseStatsCell(tableView: UITableView,
                                       indexPath: IndexPath,
                                       course: Course?) -> CourseStatsTableViewCell {
        let cell: CourseStatsTableViewCell = tableView.dequeCell(at: indexPath)
        TableCellStyle.apply(to: cell, course: course)
        cell.selectionStyle = .none
        cell.backgroundColor = AppStyle.Color.backgroundSecondary
        return cell
    }

    private func createDoubleButtonCell(tableView: UITableView,
                                        indexPath: IndexPath,
                                        course: Course) -> DoubleButtonTableViewCell {
        let cell: DoubleButtonTableViewCell = tableView.dequeCell(at: indexPath)

        let buttonTitle = CourseInfoViewModel.getButtonTitle(for: course)
        cell.rightButton.setTitle(buttonTitle, for: .normal)
        cell.rightButton.backgroundColor = AppStyle.Color.buttonMain

        let examTitle = Localization.string("course_info.exam.button")
        cell.leftButton.setTitle(examTitle, for: .normal)
        cell.leftButton.setTitleColor(AppStyle.Color.main, for: .normal)
        cell.leftButton.setTitleColor(AppStyle.Color.textDeselected, for: .disabled)
        let examEnabled = UIImage(named: "exam.enabled")?.withRenderingMode(.alwaysOriginal)
        cell.leftButton.setImage(examEnabled, for: .normal)
        let examDisabled = UIImage(named: "exam.disabled")?.withRenderingMode(.alwaysOriginal)
        cell.leftButton.setImage(examDisabled, for: .disabled)
        cell.leftButton.backgroundColor = UIColor.clear
        cell.leftButton.layer.borderWidth = AppStyle.Border.default

        let courseExams = course.materials?.filter({
            $0.documentType == Material.DocumentType.exam
        }) ?? []
        let lastAvailableExam = courseExams.last(where: { $0.isActive == true })
        cell.leftButton.isHidden = courseExams.isEmpty
        cell.leftButton.isEnabled = (lastAvailableExam != nil)
        cell.leftButton.layer.borderColor = (lastAvailableExam != nil)
            ? AppStyle.Color.main.cgColor : AppStyle.Color.textDeselected.cgColor

        cell.backgroundColor = AppStyle.Color.backgroundSecondary
        cell.selectionStyle = .none

        cell.onPressLeft = { [weak self] in // opening available exam
            guard let material = lastAvailableExam else { return }
            self?.output.openQuestions(for: material, from: course)
        }
        cell.onPressRight = { [weak self] in // proceeding course
            self?.output.runCourse(self?.viewModel?.course)
        }

        return cell
    }

    private func createMaterialCell(tableView: UITableView,
                                    indexPath: IndexPath,
                                    course: Course?,
                                    material: Material?) -> UITableViewCell {
        guard let docType = material?.documentType else {
            return UITableViewCell()
        }

        switch docType {
        case .chapter:
            let cell: AppointmentChapterTableViewCell = tableView.dequeCell(at: indexPath)
            TableCellStyle.apply(to: cell, material: material)
            return cell
        case .test, .exam:
            let cell: AppointmentTestTableViewCell = tableView.dequeCell(at: indexPath)
            TableCellStyle.apply(to: cell, material: material)
            return cell
        }
    }

    private func createAboutCell(tableView: UITableView,
                                 indexPath: IndexPath,
                                 text: String?) -> UITableViewCell {
        let cell: TextTableViewCell = tableView.dequeCell(at: indexPath)

        cell.insets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        cell.contentLabel.numberOfLines = 0
        cell.contentLabel.font = AppStyle.Font.light(16)
        cell.contentLabel.textColor = AppStyle.Color.textMain
        cell.contentLabel.text = text
        cell.selectionStyle = .none

        return cell
    }

    private func createTitleCell(tableView: UITableView,
                                 indexPath: IndexPath,
                                 insets: UIEdgeInsets,
                                 text: String?) -> TextTableViewCell {
        let cell: TextTableViewCell = tableView.dequeCell(at: indexPath)

        cell.insets = insets
        cell.contentLabel.numberOfLines = 0
        cell.contentLabel.font = AppStyle.Font.medium(20)
        cell.contentLabel.textColor = AppStyle.Color.textMain
        cell.contentLabel.text = text
        cell.selectionStyle = .none

        return cell
    }

    private func createTagsCell(tableView: UITableView,
                                indexPath: IndexPath,
                                tags: [String]) -> TagsTableViewCell {
        let cell: TagsTableViewCell = tableView.dequeCell(at: indexPath)
        cell.titleLabel.text = Localization.string("course_info.tags.title")
        cell.setupWithTags(tags)
        cell.onNeedUpdateHeight = {
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
        cell.selectionStyle = .none

        return cell
    }

    private func createRewardsCell(tableView: UITableView,
                                   indexPath: IndexPath) -> RewardsTableViewCell {
        let cell: RewardsTableViewCell = tableView.dequeCell(at: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = AppStyle.Color.backgroundMain

        // TODO: remove demo data later
        cell.rewardsView.showDemoData()

        return cell
    }
}

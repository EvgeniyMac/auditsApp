////
////  ResultViewController+UITableViewDelegate.swift
////  Education
////
////  Created by Andrey Medvedev on 21/04/2019.
////  Copyright © 2019 ООО Офис 365. All rights reserved.
////
//
//import UIKit
//import Charts
//
//extension ResultViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return kTableSectionHeaderHeight
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 0 {
//            return tableView.frame.width * kTableChartCellSizeRatio
//        }
//        return UITableView.automaticDimension
//    }
//}
//
//extension ResultViewController: UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return 1
//        } else {
//            return self.questionnaire?.questionItems.count ?? 0
//        }
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 1 {
//            let header = MarginLabel()
//            header.text = Localization.string("result.questions_section_title")
//            header.font = AppStyle.Font.regular(20)
//            header.textColor = AppStyle.Color.textMain
//            header.insets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
//            return header
//        }
//        return UIView()
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == 0 {
//            return createChartCell(tableView: tableView,
//                                   indexPath: indexPath,
//                                   questionnaire: self.questionnaire)
//        } else {
//            let item = self.questionnaire?.questionItems[indexPath.row]
//            return createQuestionCell(tableView: tableView,
//                                      indexPath: indexPath,
//                                      item: item)
//        }
//    }
//
//    private func createChartCell(tableView: UITableView,
//                                 indexPath: IndexPath,
//                                 questionnaire: Questionnaire?) -> ResultChartTableViewCell {
//        guard let cell = tableView.dequeueReusableCell(
//            withIdentifier: ResultChartTableViewCell.reuseIdentifier(),
//            for: indexPath) as? ResultChartTableViewCell else {
//                fatalError("Unable to create ResultChartTableViewCell")
//        }
//
//        guard let questionnaire = questionnaire else {
//            cell.totalTimeLabel.text = nil
//            cell.totalAnswersLabel.text = nil
//            return cell
//        }
//
//        let questionsTotal = questionnaire.questionsTotal
//        let questionsCorrect = questionnaire.questionsCorrect
//        cell.totalAnswersLabel.text = "\(questionsCorrect) / \(questionsTotal)"
//
//        let entries = [PieChartDataEntry(value: Double(questionsCorrect)),
//                       PieChartDataEntry(value: Double(questionsTotal - questionsCorrect))]
//        let dataset = PieChartDataSet(values: entries, label: nil)
//        dataset.colors = [AppStyle.Color.success, AppStyle.Color.failure]
//        dataset.selectionShift = 0
//        dataset.drawValuesEnabled = false
//        let data = PieChartData(dataSet: dataset)
//        cell.pieChartView.data = data
//
//        let totalTime = questionnaire.getTotalAnswerTime()
//        cell.totalTimeLabel.text = totalTime.readableString()
//
//        return cell
//    }
//
//    private func createQuestionCell(tableView: UITableView,
//                                    indexPath: IndexPath,
//                                    item: Questionnaire.Item?) -> ResultQuestionTableViewCell {
//        guard let cell = tableView.dequeueReusableCell(
//            withIdentifier: ResultQuestionTableViewCell.reuseIdentifier(),
//            for: indexPath) as? ResultQuestionTableViewCell else {
//                fatalError("Unable to create ResultQuestionTableViewCell")
//        }
//
//        cell.questionLabel.text = item?.question.questionText
//        if let isCorrect = item?.answer?.isCorrect {
//            let image = isCorrect ? AppStyle.Image.answerCorrect : AppStyle.Image.answerIncorrect
//            cell.resultImageView.image = image
//        } else {
//            cell.resultImageView.image = nil
//        }
//
//        return cell
//    }
//}

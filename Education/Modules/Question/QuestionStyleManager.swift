//
//  QuestionStyleManager.swift
//  Education
//
//  Created by Andrey Medvedev on 25/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class QuestionStyleManager {
    static func setupTrueFalseView(_ v: DoubleOptionView,
                                   isAnswered: Bool,
                                   userAnswer: Bool?,
                                   correctAnswer: Bool?) {
        let trueTitle = Localization.string("answer_bool_cell.true_button")
        self.setupTrueFalseButton(v.leftOptionButton,
                                  enabled: !isAnswered,
                                  withTitle: trueTitle)
        let falseTitle = Localization.string("answer_bool_cell.false_button")
        self.setupTrueFalseButton(v.rightOptionButton,
                                  enabled: !isAnswered,
                                  withTitle: falseTitle)

        if isAnswered {
            if correctAnswer == true {
                v.leftOptionButton.setImage(AppStyle.Image.answerCorrect, for: .normal)
                v.leftOptionButton.tintColor = AppStyle.Color.success
                v.rightOptionButton.setImage(AppStyle.Image.answerIncorrect, for: .normal)
                v.rightOptionButton.tintColor = AppStyle.Color.failure
            } else {
                v.leftOptionButton.setImage(AppStyle.Image.answerIncorrect, for: .normal)
                v.leftOptionButton.tintColor = AppStyle.Color.failure
                v.rightOptionButton.setImage(AppStyle.Image.answerCorrect, for: .normal)
                v.rightOptionButton.tintColor = AppStyle.Color.success
            }

            let highlightColor = AppStyle.Color.backgroundSecondary
            v.leftOptionButton.backgroundColor = userAnswer == true ? highlightColor : .clear
            v.rightOptionButton.backgroundColor = userAnswer == false ? highlightColor : .clear
        } else {
            v.leftOptionButton.backgroundColor = AppStyle.Color.buttonTrue
            v.rightOptionButton.backgroundColor = AppStyle.Color.buttonFalse
        }
    }

    private static func setupTrueFalseButton(_ button: UIButton,
                                             enabled: Bool,
                                             withTitle: String) {
        button.setTitle(withTitle, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        button.isUserInteractionEnabled = enabled

        if enabled {
            button.setTitleColor(AppStyle.Color.buttonSupplementary, for: .normal)
        } else {
            button.setTitleColor(AppStyle.Color.textMain, for: .normal)
        }
    }

    // MARK: - Cells
    static func createImageCell(tableView: UITableView,
                                indexPath: IndexPath,
                                imageUrl: URL,
                                maxHeight: CGFloat,
                                onLoadImage: ((UIImage?) -> Void)?) -> AnswerImageTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AnswerImageTableViewCell.reuseIdentifier(),
            for: indexPath) as? AnswerImageTableViewCell else {
                fatalError("Unable to create AnswerImageTableViewCell")
        }

        let imageSizeMax = CGSize(width: UIScreen.main.bounds.width,
                                  height: maxHeight)
        cell.loadImage(fromUrl: imageUrl,
                       maxSize: imageSizeMax,
                       completion: { (image) in
                           onLoadImage?(image)
                           UIView.setAnimationsEnabled(false)
                           tableView.beginUpdates()
                           tableView.reloadRows(at: [indexPath], with: .none)
                           tableView.endUpdates()
                           UIView.setAnimationsEnabled(true)
        })
        cell.selectionStyle = .none
        return cell
    }

    static func createImageCell(tableView: UITableView,
                                indexPath: IndexPath,
                                image: UIImage?,
                                maxHeight: CGFloat) -> AnswerImageTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AnswerImageTableViewCell.reuseIdentifier(),
            for: indexPath) as? AnswerImageTableViewCell else {
                fatalError("Unable to create AnswerImageTableViewCell")
        }

        let imageSizeMax = CGSize(width: UIScreen.main.bounds.width,
                                  height: maxHeight)
        cell.updateWithImage(image, maxSize: imageSizeMax)
        cell.selectionStyle = .none
        return cell
    }

    static func createResultImageCell(tableView: UITableView,
                                      indexPath: IndexPath,
                                      image: UIImage?) -> AnswerResultTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AnswerResultTableViewCell.reuseIdentifier(),
            for: indexPath) as? AnswerResultTableViewCell else {
                fatalError("Unable to create AnswerResultTableViewCell")
        }

        cell.resultImageView.image = image
        cell.selectionStyle = .none
        return cell
    }

    static func createTextCell(tableView: UITableView,
                               indexPath: IndexPath) -> TextTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TextTableViewCell.reuseIdentifier(),
            for: indexPath) as? TextTableViewCell else {
                fatalError("Unable to create TextTableViewCell")
        }

        cell.selectionStyle = .none
        return cell
    }

    static func createAnswerTextCell(tableView: UITableView,
                                     indexPath: IndexPath) -> AnswerTextTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AnswerTextTableViewCell.reuseIdentifier(),
            for: indexPath) as? AnswerTextTableViewCell else {
                fatalError("Unable to create AnswerTextTableViewCell")
        }

        cell.textField.font = AppStyle.Font.regular(18)
        cell.textField.textColor = AppStyle.Color.textMain
        cell.selectionStyle = .none
        return cell
    }

    static func createAnswerBoolCell(tableView: UITableView,
                                     indexPath: IndexPath) -> AnswerBoolTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AnswerBoolTableViewCell.reuseIdentifier(),
            for: indexPath) as? AnswerBoolTableViewCell else {
                fatalError("Unable to create AnswerBoolTableViewCell")
        }

        cell.selectionStyle = .none
        return cell
    }

    static func createAnswerOptionCell(tableView: UITableView,
                                       indexPath: IndexPath) -> AnswerOptionTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AnswerOptionTableViewCell.reuseIdentifier(),
            for: indexPath) as? AnswerOptionTableViewCell else {
                fatalError("Unable to create AnswerOptionTableViewCell")
        }

        cell.selectionStyle = .none
        return cell
    }

    static func createAnswerTilesCell(tableView: UITableView,
                                      indexPath: IndexPath) -> AnswerTilesTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AnswerTilesTableViewCell.reuseIdentifier(),
            for: indexPath) as? AnswerTilesTableViewCell else {
                fatalError("Unable to create AnswerTilesTableViewCell")
        }

        cell.selectionStyle = .none
        return cell
    }

    static func createAnswerSequenceCell(tableView: UITableView,
                                         indexPath: IndexPath) -> AnswerSequenceTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AnswerSequenceTableViewCell.reuseIdentifier(),
            for: indexPath) as? AnswerSequenceTableViewCell else {
                fatalError("Unable to create AnswerSequenceTableViewCell")
        }

        cell.selectionStyle = .none
        return cell
    }

    static func createTextCloudCell(tableView: UITableView,
                                    indexPath: IndexPath) -> TextCloudTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TextCloudTableViewCell.reuseIdentifier(),
            for: indexPath) as? TextCloudTableViewCell else {
                fatalError("Unable to create TextCloudTableViewCell")
        }

        cell.selectionStyle = .none
        return cell
    }
}

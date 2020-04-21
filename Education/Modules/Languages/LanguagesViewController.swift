//
//  LanguagesViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 04/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class LanguagesViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

    private var languages = Localization.Language.allCases

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureTable()
        localizeUI()
    }

    // MARK: - Overridings
    override func localizeUI() {
        super.localizeUI()
        self.title = Localization.string("languages.navigation_bar_title")
        self.tableView.reloadData()
    }

    // MARK: - Private
    private func configureUI() {
        self.view.backgroundColor = AppStyle.Color.backgroundMain
    }

    private func configureTable() {
        self.tableView.backgroundColor = AppStyle.Color.backgroundMain

        let cellNib = UINib(nibName: ProfileTableViewCell.reuseIdentifier(), bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: ProfileTableViewCell.reuseIdentifier())
    }
}

extension LanguagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        let language = self.languages[indexPath.row]
        if Localization.language != language {
            Localization.language = language
        }
    }
}

extension LanguagesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.languages.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AppStyle.Table.rowHeightDefault
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let language = self.languages[indexPath.row]
        return createProfileCell(tableView: tableView,
                                 indexPath: indexPath,
                                 text: language.title,
                                 isSelected: Localization.language == language)
    }

    private func createProfileCell(tableView: UITableView,
                                   indexPath: IndexPath,
                                   text: String,
                                   isSelected: Bool) -> ProfileTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ProfileTableViewCell.reuseIdentifier(),
            for: indexPath) as? ProfileTableViewCell else {
                fatalError("Unable to create ProfileTableViewCell")
        }

        cell.titleLabel.text = text
        let image = isSelected ? UIImage(named: "state_completed_icon") : nil
        cell.rightImageView.image = image

        return cell
    }
}

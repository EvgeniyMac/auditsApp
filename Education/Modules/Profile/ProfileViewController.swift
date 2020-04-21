//
//  ProfileViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 03/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class ProfileViewController: BaseViewController {
    enum ProfileRow: Int, CaseIterable {
        case info = 0
        case language
        case logout

        var title: String? {
            switch self {
            case .info:
                return nil
            case .language:
                return Localization.string("profile.language")
            case .logout:
                return Localization.string("profile.logout")
            }
        }
    }

    @IBOutlet weak var tableView: UITableView!
    private var currentUser: User?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.currentUser = UsersRepo.shared.getCurrentUser()

        configureUI()
        configureTable()
        localizeUI()
        updateProfileInfo()
    }

    // MARK: - Overridings
    override func localizeUI() {
        super.localizeUI()
        self.title = Localization.string("profile.navigation_bar_title")
        self.tableView.reloadData()
    }

    // MARK: - Private
    private func configureUI() {
        self.view.backgroundColor = AppStyle.Color.backgroundMain
    }

    private func configureTable() {
        self.tableView.backgroundColor = AppStyle.Color.backgroundMain

        let infoCellNib = UINib(nibName: UserInfoTableViewCell.reuseIdentifier(), bundle: nil)
        self.tableView.register(infoCellNib, forCellReuseIdentifier: UserInfoTableViewCell.reuseIdentifier())
        let cellNib = UINib(nibName: ProfileTableViewCell.reuseIdentifier(), bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: ProfileTableViewCell.reuseIdentifier())
    }

    private func openLanguageSettings() {
        self.performSegue(withIdentifier: "toLanguagesViewController", sender: nil)
    }

    private func updateProfileInfo() {
        UsersRepo.shared.loadCurrentUser { [weak self] (user) in
            self?.currentUser = user
            let userInfoIndexPath = IndexPath(row: ProfileRow.info.rawValue, section: 0)
            self?.tableView.reloadRows(at: [userInfoIndexPath], with: .none)
        }
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        guard let row = ProfileRow(rawValue: indexPath.row) else {
            fatalError("Profile - incorrect row was selected")
        }

        switch row {
        case .language:
            openLanguageSettings()
        case .logout:
            let action = {
                UserManager.logout()
            }
            requestConfirmation(action: action,
                                message: Localization.string("common.logout.request"),
                                confirmText: Localization.string("common.logout"),
                                declineText: Localization.string("common.cancel"))
        default:
            break
        }
    }
}

extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProfileRow.allCases.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let row = ProfileRow(rawValue: indexPath.row) else {
            fatalError("Profile - incorrect row height")
        }

        switch row {
        case .info:
            return UITableView.automaticDimension
        case .language, .logout:
            return AppStyle.Table.rowHeightDefault
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = ProfileRow(rawValue: indexPath.row) else {
            fatalError("Profile - incorrect row was selected")
        }

        switch row {
        case .info:
            return createUserInfoCell(tableView: tableView,
                                      indexPath: indexPath,
                                      user: self.currentUser)
        case .language, .logout:
            return createProfileCell(tableView: tableView,
                                     indexPath: indexPath,
                                     row: row)
        }
    }

    private func createUserInfoCell(tableView: UITableView,
                                    indexPath: IndexPath,
                                    user: User?) -> UserInfoTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: UserInfoTableViewCell.reuseIdentifier(),
            for: indexPath) as? UserInfoTableViewCell else {
                fatalError("Unable to create UserInfoTableViewCell")
        }

        cell.avatarView.monogramLabel.font = AppStyle.Font.regular(44)
        if let url = user?.logo {
            cell.avatarView.avatarImageView.af_setImage(withURL: url)
            cell.avatarView.monogramLabel.text = nil
        } else if let firstNameCharacter = user?.name?.first {
            cell.avatarView.avatarImageView.image = nil
            cell.avatarView.monogramLabel.text = String(firstNameCharacter)
        } else {
            cell.avatarView.avatarImageView.image = nil
            cell.avatarView.monogramLabel.text = nil
        }

        let roleParts = [user?.position, user?.division].compactMap({ $0 })
        let partsSeparator = " \(Localization.string("common.preposition_at_division")) "
        cell.roleLabel.text = roleParts.joined(separator: partsSeparator)

        cell.nameLabel.text = user?.name
        cell.selectionStyle = .none

        return cell
    }

    private func createProfileCell(tableView: UITableView,
                                   indexPath: IndexPath,
                                   row: ProfileRow) -> ProfileTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ProfileTableViewCell.reuseIdentifier(),
            for: indexPath) as? ProfileTableViewCell else {
                fatalError("Unable to create ProfileTableViewCell")
        }

        cell.titleLabel.text = row.title
        if row == .language {
            cell.rightImageView.image = UIImage(named: "row_arrow_right")
        }

        return cell
    }
}

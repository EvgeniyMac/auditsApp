//
//  BarActionView.swift
//  Education
//
//  Created by Andrey Medvedev on 14/10/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class BarActionView: UIView {
    typealias Button = UIButton

    private static let barStackSpacingDefault: CGFloat = 8
    private static let barStackSpacingSmall: CGFloat = 0

    enum Action {
        case search
        case profile
        case settings
        case bookmark
        case custom(button: BarActionView.Button)
    }

    public var itemSize = CGSize(width: 33, height: 33)
    public var onPressSettings: (() -> Void)?
    public var onPressProfile: (() -> Void)?
    public var onPressBookmark: ((Bool) -> Void)?

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.backgroundColor = UIColor.clear

        switch UIDevice().screenType {
        case .iPhones_4_4S, .iPhones_5_5s_5c_SE:
            stack.spacing = BarActionView.barStackSpacingSmall
        default:
            stack.spacing = BarActionView.barStackSpacingDefault
        }

        return stack
    }()

    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "search_icon"), for: .normal)

        button.frame.origin = .zero
        button.frame.size = AppStyle.NavigationBar.buttonSize
        let buttonSize = AppStyle.NavigationBar.buttonSize
        button.addConstraints(button.createSizeConstraints(size: buttonSize))

        let selector = #selector(didPressSearchButton(sender:))
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }()

    private lazy var settingsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "settings_icon"), for: .normal)

        button.frame.origin = .zero
        button.frame.size = AppStyle.NavigationBar.buttonSize
        let buttonSize = AppStyle.NavigationBar.buttonSize
        button.addConstraints(button.createSizeConstraints(size: buttonSize))

        let selector = #selector(didPressSettingsButton(sender:))
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }()

    public lazy var bookmarkButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "bookmark_icon.selected"), for: .selected)
        button.setImage(UIImage(named: "bookmark_icon.deselected"), for: .normal)

        button.frame.origin = .zero
        button.frame.size = AppStyle.NavigationBar.buttonSize
        let buttonSize = AppStyle.NavigationBar.buttonSize
        button.addConstraints(button.createSizeConstraints(size: buttonSize))

        let selector = #selector(didPressBookmarkButton(sender:))
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }()

    private lazy var avatarView: AvatarView = {
        let avatarView = AvatarView()
        avatarView.translatesAutoresizingMaskIntoConstraints = false

        let avatarViewSize = AppStyle.NavigationBar.buttonSize
        avatarView.frame = CGRect(origin: .zero, size: avatarViewSize)
        avatarView.addConstraints(avatarView.createSizeConstraints(size: avatarViewSize))

        avatarView.containerView.backgroundColor = AppStyle.Color.avatarBackground
        avatarView.monogramLabel.textColor = AppStyle.Color.textMain
        avatarView.monogramLabel.font = AppStyle.Font.regular(14)
        let selector = #selector(didPressProfileButton(sender:))
        avatarView.avatarButton.addTarget(self, action: selector, for: .touchUpInside)
        avatarView.avatarButton.backgroundColor = .clear

        return avatarView
    }()

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.clear
        setupBarActionViewLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.backgroundColor = UIColor.clear
        setupBarActionViewLayout()
    }

    // MARK: - Overridings

    // MARK: - Public
    public func setupBarItem(withActions: [Action]) {
        self.stackView.removeAllArrangedSubviews()

        let actionsCount = CGFloat(withActions.count)
        self.frame.size.width = self.itemSize.width * actionsCount
        self.frame.size.height = self.itemSize.height

        withActions.forEach { (action) in
            switch action {
            case .search:
                appendActionView(self.searchButton)
            case .profile:
                appendActionView(self.avatarView)
                updateAvatarView(self.avatarView)
            case .settings:
                appendActionView(self.settingsButton)
            case .bookmark:
                appendActionView(self.bookmarkButton)
            case .custom(let button):
                appendActionView(button)
            }
        }
    }

    public func reloadBarItem(withAction: Action) {
        switch withAction {
        case .profile:
            updateAvatarView(self.avatarView)
        default:
            break
        }
    }

    public static func createBarActionButton(image: UIImage?) -> BarActionView.Button {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image, for: .normal)
        button.frame.origin = .zero
        button.frame.size = AppStyle.NavigationBar.buttonSize
        let buttonSize = AppStyle.NavigationBar.buttonSize
        button.addConstraints(button.createSizeConstraints(size: buttonSize))
        return button
    }

    // MARK: - Actions
    @objc private func didPressSearchButton(sender: Any) {
        print("didPressSearchButton")
    }

    @objc private func didPressProfileButton(sender: Any) {
        print("didPressProfileButton")
        self.onPressProfile?()
    }

    @objc private func didPressSettingsButton(sender: Any) {
        print("didPressSettingsButton")
        self.onPressSettings?()
    }

    @objc private func didPressBookmarkButton(sender: UIButton) {
        print("didPressBookmarkButton")
        self.onPressBookmark?(!sender.isSelected)
    }

    // MARK: - Private
    private func setupBarActionViewLayout() {
        self.addSubview(self.stackView)
        let constraints = self.createContiguousConstraints(toView: self.stackView)
        self.addConstraints(constraints)
    }

    private func appendActionView(_ view: UIView) {
        guard !self.stackView.arrangedSubviews.contains(view) else {
            return
        }

        self.stackView.addArrangedSubview(view)
    }

    private func updateAvatarView(_ avatarView: AvatarView) {
        if let user = UsersRepo.shared.getCurrentUser() {
            setupAvatarView(avatarView, for: user)
        } else {
            UsersRepo.shared.loadCurrentUser { (user) in
                if let user = user {
                    self.setupAvatarView(avatarView, for: user)
                }
            }
        }
    }

    private func setupAvatarView(_ avatarView: AvatarView, for user: User) {
        if let url = user.logo {
            avatarView.monogramLabel.text = nil
            avatarView.avatarImageView.af_setImage(withURL: url, completion: {
                [weak self, weak avatarView] (response) in
                switch response.result {
                case .success(let image):
                    avatarView?.avatarImageView.image = image
                case .failure(_):
                    if let aView = avatarView {
                        self?.setupMonogamAvatar(at: aView, for: user)
                    }
                }
            })
        } else {
            setupMonogamAvatar(at: avatarView, for: user)
        }
    }

    private func setupMonogamAvatar(at avatarView: AvatarView, for user: User?) {
        avatarView.avatarImageView.image = nil
        if let firstNameCharacter = user?.name?.first {
            avatarView.monogramLabel.text = String(firstNameCharacter)
        } else {
            avatarView.monogramLabel.text = nil
        }
    }
}

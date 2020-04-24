//
//  TabNavigationController.swift
//  Education
//
//  Created by Andrey Medvedev on 30/09/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

protocol TabNavigationPushHandling {
    func handlePushNotification(data: PushNotificationData?)
}

class TabNavigationController: UINavigationController {

    private var pendingPushNotification: PushNotificationData?
    private var pushNotificationObserver: Any?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureNavigationBar()
        DispatchQueue.main.async { [weak self] in
            if let data = self?.pendingPushNotification {
                self?.handlePushNotification(data: data)
            }
        }
    }

    deinit {
        print("DEINIT: \(String(describing: self))")
    }

    // MARK: - Actions
    @objc private func didPressProfileButton(sender: Any) {
        self.performSegue(withIdentifier: "toProfile", sender: nil)
    }

    // MARK: - Private
    private func configureUI() {
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: AppStyle.Font.medium(22)]

        let bgColor = AppStyle.Color.navigationBarBackground
        self.navigationBar.barTintColor = bgColor
        self.navigationBar.tintColor = AppStyle.Color.navigationBarTint

        if #available(iOS 11.0, *) {
            // making navigation bar transparent
            self.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationBar.isTranslucent = true
        } else {
            let bgImage = UIImage(color: AppStyle.Color.white)
            self.navigationBar.setBackgroundImage(bgImage, for: .default)
            self.navigationBar.isTranslucent = false
        }

        if #available(iOS 11.0, *) {
            // setting large titles attributes
            let attributes = AppStyle.Text.largeTitleDefault
            self.navigationBar.largeTitleTextAttributes = attributes
        }
    }

    private func configureNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.hidesBackButton = true

        let label = UILabel(frame: .zero)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: String(),
                                                                style: .plain,
                                                                target: nil,
                                                                action: nil)

//        let avatarView = AvatarView()
//        avatarView.containerView.backgroundColor = AppStyle.Color.avatarBackground
//        avatarView.monogramLabel.textColor = AppStyle.Color.textMain
//        avatarView.monogramLabel.font = AppStyle.Font.regular(14)
//        let selector = #selector(didPressProfileButton(sender:))
//        avatarView.avatarButton.addTarget(self, action: selector, for: .touchUpInside)
//        avatarView.avatarButton.backgroundColor = .clear
//
//        if let user = UsersRepo.shared.getCurrentUser() {
//            setupAvatarView(avatarView, for: user)
//        } else {
//            UsersRepo.shared.loadCurrentUser { (user) in
//                if let user = user {
//                    self.setupAvatarView(avatarView, for: user)
//                }
//            }
//        }
//
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: avatarView)
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

extension TabNavigationController: TabNavigationPushHandling {
    // MARK: - TabNavigationPushHandling
    open func handlePushNotification(data: PushNotificationData?) {
        if let courseId = data?.appointmentId {
            // Course
            openCourseInfo(courseId: courseId)
        } else if let articleId = data?.articleId {
            // NewsItem
            openNewsItem(articleId: articleId)
        }
    }

    private func openCourseInfo(courseId: String) {
        CoursesService.loadCourse(courseId: courseId,
                                  success: { (course) in
                                    self.openCourseInfo(course: course)
        },
                                  failure: { _ in })
    }

    private func openCourseInfo(course: Course) {
        let storyboard = UIStoryboard(name: "Courses", bundle: nil)
        let controller = storyboard.instantiateViewController(
            withIdentifier: "CourseInfoViewControllerID")
        if let vc = controller as? CourseInfoViewController {
            vc.setup(withCourse: course)
            self.pushViewController(vc, animated: true)
        }
    }

    private func openNewsItem(articleId: String) {
        NewsService.getArticle(articleId: articleId,
                               success: { (newsItem) in
                                self.openNewsItem(newsItem: newsItem)
        },
                               failure: { _ in })
    }

    private func openNewsItem(newsItem: NewsItem) {
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let controller = storyboard.instantiateViewController(
            withIdentifier: "NewsItemViewControllerID")
        if let vc = controller as? NewsItemViewController {
            vc.newsItem = newsItem
            self.pushViewController(vc, animated: true)
        }
    }
}

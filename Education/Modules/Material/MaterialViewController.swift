//
//  MaterialViewController.swift
//  Education
//
//  Created by Andrey Medvedev on 24/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit
import WebKit

protocol MaterialViewOutput {
    func viewIsReady()
    func viewDidAppear()
    func viewWillDisappear()
    func moduleDeinited()
    func openQuestions(using questionnaire: Questionnaire)
    func shouldMarkLessonAsPassed()
}

protocol MaterialViewInput: class {
    func showProgressIndicator()
    func hideProgressIndicator()
    func showError(_ error: NetworkError,
                   onRetry: (() -> Void)?,
                   onDismiss: (() -> Void)?)
    func showErrorMessage(forError error: NetworkError)

    func configureWith(material: Material?, from course: Course?)
}

class MaterialViewController: BaseViewController, MaterialViewInput {

    var output: MaterialViewOutput!

    var material: Material?
    var course: Course?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var descriptionContainerView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var webContainerView: UIView!
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var actionButton: CustomButton!
    @IBOutlet var webContainerHeightConstraint: NSLayoutConstraint!

    private let kTitleAppearanceOffset = CGFloat(200)
    private lazy var titleLabel: AppearingNavigationLabel = {
        let label = AppearingNavigationLabel()
        label.totalAppearanceValueMin = kTitleAppearanceOffset
        label.text = nil
        label.numberOfLines = 2
        label.font = AppStyle.Font.medium(20)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textColor = AppStyle.Color.navigationBarTint
        label.alpha = AppStyle.Alpha.hidden
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.output.viewIsReady()

        self.titleLabel.text = self.material?.name

        configureUI()
        applyMaterial(self.material)
    }

    deinit {
        self.output.moduleDeinited()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.output.viewDidAppear()

        if let appearingLabel = self.navigationItem.titleView as? AppearingNavigationLabel {
            appearingLabel.updateTitleView(value: 0)
        } else {
            self.navigationItem.titleView = self.titleLabel
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.output.viewWillDisappear()

        self.navigationItem.titleView = nil
    }

    override func shouldHideTabBar() -> Bool {
        return true
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        let barView = BarActionView()
        barView.setupBarItem(withActions: [.settings])
        let barItem = UIBarButtonItem(customView: barView)
        self.navigationItem.rightBarButtonItems = [barItem]
    }

    func configureWith(material: Material?, from course: Course?) {
        self.material = material
        self.course = course

        if self.isViewLoaded {
            applyMaterial(material)
        }
    }

    // MARK: - Actions
    @IBAction func didPressActionButton(_ sender: Any) {
        guard let material = self.material,
            let materialType = self.material?.documentType else {
                return
        }

        switch materialType {
        case .test, .exam:
            guard let material = self.material,
                let course = self.course else {
                    showErrorMessage(forError: .insufficientRequestData)
                    return
            }

            let questionnaire = Questionnaire(with: material, from: course)
            self.output.openQuestions(using: questionnaire)
        case .chapter:
            self.output.shouldMarkLessonAsPassed()
        }
    }

    // MARK: - Private
    private func configureUI() {
        self.scrollView.delegate = self

        self.descriptionLabel.font = AppStyle.Font.semibold(24)
        self.descriptionLabel.textColor = AppStyle.Color.textMain
        self.descriptionLabel.numberOfLines = 0
        self.actionButton.backgroundColor = AppStyle.Color.buttonMain

        guard let docType = self.material?.documentType else { return }
        switch docType {
        case .test, .exam:
            let buttonTitle = Localization.string("material.test_start_button")
            self.actionButton.setTitle(buttonTitle, for: .normal)
        case .chapter:
            let buttonTitle = Localization.string("material.lesson_finished_button")
            self.actionButton.setTitle(buttonTitle, for: .normal)
        }
    }

    private func applyMaterial(_ material: Material?) {
        guard let materialType = material?.documentType else {
            return
        }

        self.descriptionLabel.text = nil

        switch materialType {
        case .chapter:
            self.descriptionContainerView.isHidden = false
            self.buttonContainerView.isHidden = true

            self.descriptionLabel.text = material?.name

            if let html = material?.contentHTML {
                let webView = createWebView(using: html)
                webContainerView.addSubview(webView)
                let constraints = webContainerView.createContiguousConstraints(toView: webView)
                webContainerView.addConstraints(constraints)
            }
        case .test, .exam:
            self.descriptionContainerView.isHidden = true
            self.buttonContainerView.isHidden = false

            self.descriptionLabel.text = nil
            self.webContainerView.subviews.forEach { (subview) in
                subview.removeFromSuperview()
            }

            fitStackToScreen()
        }
    }

    private func fitStackToScreen() {
        // WORKAROUND: workaround to implement requirements
        self.webContainerHeightConstraint.isActive = false
        let constraint = NSLayoutConstraint(item: self.stackView,
                                            attribute: .centerY,
                                            relatedBy: .equal,
                                            toItem: self.scrollView,
                                            attribute: .centerY,
                                            multiplier: 1.0,
                                            constant: 0.0)
        self.scrollView.addConstraint(constraint)
    }

    private func createWebView(using html: String) -> WKWebView {
        let webView = WKWebView(frame: .zero,
                                configuration: webViewConfiguration())
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.loadHTMLString(html, baseURL: nil)

        // disabling scroll using inner ScrollView to perform scrolling using outer ScrollView
        webView.scrollView.isScrollEnabled = false
        return webView
    }

    private func webViewConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController()
        return configuration
    }

    private func userContentController() -> WKUserContentController {
        let controller = WKUserContentController()
        controller.addUserScript(viewPortScript())
        return controller
    }

    private func viewPortScript() -> WKUserScript {
        let viewPortScript = """
            var meta = document.createElement('meta');
            meta.setAttribute('name', 'viewport');
            meta.setAttribute('content', 'width=device-width');
            meta.setAttribute('initial-scale', '1.0');
            meta.setAttribute('maximum-scale', '1.0');
            meta.setAttribute('minimum-scale', '1.0');
            meta.setAttribute('user-scalable', 'no');
            document.getElementsByTagName('head')[0].appendChild(meta);
        """
        return WKUserScript(source: viewPortScript,
                            injectionTime: .atDocumentEnd,
                            forMainFrameOnly: true)
    }
}

extension MaterialViewController: WKNavigationDelegate {

    private func update(webView: WKWebView, for height: CGFloat) {
        let webViewSpace = self.scrollView.frame.height - buttonContainerView.frame.height
        self.webContainerHeightConstraint.constant = max(height, webViewSpace)
        self.buttonContainerView.isHidden = false
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.readyState", completionHandler: { [weak webView] (complete, error) in
            guard let webView = webView,
                complete != nil else {
                    return
            }

            webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { [weak webView] (height, error) in
                guard let webView = webView,
                    let height = height as? CGFloat else {
                        return
                }
                self.update(webView: webView, for: height)
            })
        })
    }
}

extension MaterialViewController: UIScrollViewDelegate {
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let appearingLabel = self.navigationItem.titleView as? AppearingNavigationLabel {
            appearingLabel.updateTitleView(value: scrollView.contentOffset.y)
        }
    }
}

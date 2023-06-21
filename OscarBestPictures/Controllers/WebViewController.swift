//
//  WebViewController.swift
//  OscarBestPictures
//
//  Created by Yves Yang on 5/4/23.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    // Declare url variable, buttons variables, and webView variable
    private let url: URL
    var backButton: UIBarButtonItem!
    var forwardButton: UIBarButtonItem!
    var refreshButton: UIBarButtonItem!
    var shareButton: UIBarButtonItem!
    
    private let webView: WKWebView = {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }()
    
    // Launch webView in viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(webView)
        webView.load(URLRequest(url: url))
        // Set up buttons.
        configureButtons()
        // Check and update back and forward button status.
        webView.navigationDelegate = self
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }
    
    init(url: URL, title: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // Set up buttons in webView
    private func configureButtons() {
        // Set left side Done Button
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDone))
        
        // Set right side a series of buttons
        refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(didTapRefresh))
        backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(didTapBack))
        forwardButton = UIBarButtonItem(image: UIImage(systemName: "chevron.forward"), style: .plain, target: self, action: #selector(didTapForward))
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShare))
        
        toolbarItems = [shareButton, forwardButton, backButton, refreshButton]
        navigationItem.setRightBarButtonItems(toolbarItems, animated: true)
        
        updateBackForwardState()
    }
    
    @objc private func didTapDone() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapRefresh() {
        webView.reload()
    }
    
    // Implement Back and Forward Button
    @objc private func didTapBack() {
        webView.goBack()
    }
    
    @objc private func didTapForward() {
        webView.goForward()
    }
    
    private func updateBackForwardState() {
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        updateBackForwardState()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateBackForwardState()
    }
    
    // Implement Share Button
    @objc private func didTapShare() {
        let shareItems = self.getShareItems()
        guard shareItems.isEmpty == false else { return }
        
        let alert = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        alert.popoverPresentationController?.barButtonItem = shareButton
        present(alert, animated: true)
    }
    
    private func getShareItems() -> [Any] {
        guard let url = webView.url else { return [] }
        var shareItems: [Any] = [url]
        
        if let webViewTitle = webView.title {
            shareItems.append("\(webViewTitle) (via @twostraws)")
        }
        return shareItems
    }
}

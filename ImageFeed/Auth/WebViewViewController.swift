import UIKit
import WebKit

public protocol WebViewViewControllerProtocol: AnyObject {
    var webViewPresenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
    
}

final class WebViewViewController: UIViewController, WebViewViewControllerProtocol {
    
    var webView = WKWebView()
    private let backButton = UIButton(type: .custom)
    weak var delegate: WebViewViewControllerDelegate?
    private let progressBar = UIProgressView()
    private var estimatedProgressObservation: NSKeyValueObservation?
    var webViewPresenter: WebViewPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [.new]
        ) { [weak self] _, change in
            guard let self = self, let newValue = change.newValue else { return }
            self.webViewPresenter?.didUpdateProgressValue(newValue)
        }
       
        webView.navigationDelegate = self
        webView.accessibilityIdentifier = "UnsplashWebView"
        setupWebView()
        setupBackButton()
        setupProgressBar()
        webViewPresenter?.viewDidLoad()
        navigationItem.hidesBackButton = true
    }
    //Ответственность №3
     func setProgressValue(_ newValue: Float) {
        progressBar.progress = newValue
    }
        
    func setProgressHidden(_ isHidden: Bool) {
        progressBar.isHidden = isHidden
    }
    
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    private func setupProgressBar() {
        view.addSubview(progressBar)
        progressBar.progressTintColor = .backgroundColor1A1B22
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: .init(5))
            
        ])
    }
    
    private func setupWebView() {
        view.addSubview(webView)
        webView.accessibilityIdentifier = "UnsplashWebView"
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBackButton() {
        view.addSubview(backButton)
        backButton.setImage(UIImage(named: "backward black"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 13),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func backButtonTapped() {
        delegate?.webViewViewControllerDidCancel(self)
        navigationController?.popViewController(animated: true)
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return webViewPresenter?.code(from: url)
        }
        return nil
    }
}

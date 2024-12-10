import UIKit
import WebKit

public protocol WebViewViewControllerProtocol: AnyObject {
    var webViewPresenter: WebViewPresenterProtocol? { get set}
    func load(request: URLRequest)
}


final class WebViewViewController: UIViewController, WebViewViewControllerProtocol {
    
    private let webView = WKWebView()
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
        ) { [weak self] _, _ in
            guard let self = self else { return }
            self.updateProgress()
        }
       
        webView.navigationDelegate = self
        setupWebView()
        setupBackButton()
        setupProgressBar()
        webViewPresenter?.viewDidLoad()
        navigationItem.hidesBackButton = true
    }
    //Ответственность №3
    private func updateProgress() {
        progressBar.progress = Float(webView.estimatedProgress)
        progressBar.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
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
    //Ответственность №4
    private func setupWebView() {
        view.addSubview(webView)
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
    
    //Ответственность №1, пути запросов
    private enum WebViewConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    }
}

//Ответственность №2. Метод извлечения кода авторизации и перенаправления
private func code(from navigationAction: WKNavigationAction) -> String? {
    if
        let url = navigationAction.request.url,
        let urlComponents = URLComponents(string: url.absoluteString),
        urlComponents.path == "/oauth/authorize/native",
        let items = urlComponents.queryItems,
        let codeItem = items.first(where: { $0.name == "code" })
    {
        return codeItem.value
    } else {
        return nil
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

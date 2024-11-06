import UIKit
import Foundation

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    
    private let loginIcon = UIImageView()
    private let loginButton = UIButton()
    private let oauth2TokenStorage = OAuth2TokenStorage()
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor1A1B22
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        loginIcon.image = UIImage(named: "AuthIcon")
        loginIcon.contentMode = .scaleAspectFit
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        loginIcon.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginIcon)
        
        loginButton.setTitle("Войти", for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        loginButton.backgroundColor = .nameColorFFFFFFF
        loginButton.setTitleColor(.backgroundColor1A1B22, for: .normal)
        loginButton.layer.cornerRadius = 16
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            loginIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginIcon.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            loginIcon.heightAnchor.constraint(equalToConstant: 60),
            loginIcon.widthAnchor.constraint(equalToConstant: 60),
            loginButton.topAnchor.constraint(equalTo: loginIcon.bottomAnchor, constant: 204),
            
            
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    @objc private func  loginButtonTapped() {
        let webViewController = WebViewViewController()
        webViewController.delegate = self
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
   func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        // сообщаем делегату о получении кода
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    func didReceiveAuthorizationCode(_ code: String) {
        print("Received authorization code: \(code)")
        
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        navigationController?.popViewController(animated: true)
        print("User canceled the authorization")
    }
}

import UIKit
import Foundation

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    
    private let loginIcon = UIImageView()
    private let loginButton = UIButton()
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor1A1B22
        setupUI()
        setupConstraints()
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        navigationController?.popViewController(animated: true)
        print("User canceled the authorization")
    }
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        // сообщаем делегату о получении кода
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    func didReceiveAuthorizationCode(_ code: String) {
        guard !code.isEmpty else {
            showAlert(title: "Ошибка авторизации", message: "Не удалось получить код авторизации. Попробуйте ещё раз.")
            return
        }
        
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    print("Получен токен: \(token)")
                case .failure(let error):
                    self?.handleAuthError(error)
                }
            }
        }
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
        loginButton.accessibilityIdentifier = "LoginButton"
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
        let webViewController = createWebViewModule()
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    private func createWebViewModule() -> WebViewViewController {
        let authHelper = AuthHelper()
        let webViewPresenter = WebViewPresenter(authHelper: authHelper)
        let webViewController = WebViewViewController()
        webViewController.webViewPresenter = webViewPresenter
        webViewPresenter.webView = webViewController
        webViewController.delegate = self
        return webViewController
    }
    
    private func handleAuthError(_ error: Error) {
        switch error {
        case AuthError.invalidResponse:
            showAlert(title: "Ошибка сервера", message: "Сервер вернул некорректный ответ. Попробуйте позже.")
        case AuthError.serverError(let code):
            showAlert(title: "Ошибка сервера", message: "Ошибка на сервере (код: \(code)).")
        case AuthError.invalidData:
            showAlert(title: "Ошибка данных", message: "Данные авторизации некорректны. Попробуйте ещё раз.")
        case AuthError.networkError:
            showAlert(title: "Сетевая ошибка", message: "Проверьте подключение к интернету.")
        case AuthError.unknown:
            showAlert(title: "Неизвестная ошибка", message: "Что-то пошло не так. Попробуйте ещё раз.")
        default :
            return
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ок", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { _ in
        }
        alertController.addAction(retryAction)
    }
}

enum AuthError: Error {
    case invalidResponse
    case serverError(Int)
    case invalidData
    case networkError
    case unknown
}

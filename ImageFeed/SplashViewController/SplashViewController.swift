import UIKit

final class SplashViewController: UIViewController {
    private let oauth2Service = OAuth2Service()
    private let oauth2TokenStorage = OAuth2TokenStorage()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Проверяем наличие токена
        if let token = oauth2TokenStorage.token {
            switchToTabBarController()
        } else {
            showAuthenticationScreen()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
                   assertionFailure("Invalid window configuration")
                   return
               }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")

        // Настраиваем анимацию перехода
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
            window.rootViewController = tabBarController
        }, completion: nil)
    }

    //Метод используется вместо сигвея к экрану автризации
    private func showAuthenticationScreen() {
        let authViewController = AuthViewController()
        authViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: authViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.oauth2Service.fetchOAuthToken1(code: code) { result in
                switch result {
                case .success(let token):
                    print("Token successfully fetched: \(token)") // Логируем успех
                    self.oauth2TokenStorage.token = token // Сохраняем токен
                    self.switchToTabBarController()
                case .failure(let error):
                    print("Failed to fetch token: \(error.localizedDescription)") // Логируем ошибку
                }
            }
        }
    }
}

import UIKit

final class SplashViewController: UIViewController {
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let oauth2Service = OAuth2Service()
    private let oauth2TokenStorage = OAuth2TokenStorage()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Проверяем наличие токена
        if let token = oauth2TokenStorage.token {
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
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
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? AuthViewController
            else { fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            oauth2Service.fetchOAuthToken1(code: code) { result in
                switch result {
                case .success(let token):
                    print("Token successfully fetched: \(token)") // Логируем успех
                    self.fetchOAuthToken(token) // Здесь вызываем метод сохранения токена
                    self.switchToTabBarController()
                case .failure(let error):
                    print("Failed to fetch token: \(error.localizedDescription)") // Логируем ошибку
                }
            }
        }
    }
    

    private func fetchOAuthToken(_ code: String) {
        print("Fetching token with code: \(code)")
        oauth2Service.fetchOAuthToken1(code: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.oauth2TokenStorage.token = token // Сохраняем токен
                self.switchToTabBarController()
                print("Saving token to storage: \(token)")
            case .failure(let error):
                print("Error fetching token: \(error)") // Обработка ошибки
                // TODO: Handle the error (e.g. show an alert)
                
            }
        }
    }
}

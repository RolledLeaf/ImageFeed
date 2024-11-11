import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    private var profileService: ProfileService = ProfileService.shared
    private var profile: Profile?
    
    
    private let oauth2TokenStorage = OAuth2TokenStorage()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Проверяем наличие токена
        if let token = oauth2TokenStorage.token {
            fetchProfileData(token)
            switchToTabBarController()
            print("Token found: \(token)")
        } else {
            showAuthenticationScreen()
            print("Token not found")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    func didAuthenticate(token: String) {
           // Запрос данных профиля после авторизации
           fetchProfileData(token)
       }
    
    private func fetchProfileData(_ token: String) {
        print("Starting to fetch profile data...")
        profileService.fetchProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    print("Profile successfully fetched: \(profile)")
                    self?.profile = profile
                    self?.switchToTabBarController()  // Переход на TabBarController после получения данных профиля

                case .failure(let error):
                    print("Error fetching profile: \(error.localizedDescription)")
                    self?.handleError(error)  // Обработка ошибки получения профиля
                }
            }
        }
    }

    private func switchToTabBarController() {
        print("Attempting to switch to TabBarViewController...")

        // Загружаем TabBarController из Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as? UITabBarController else {
            print("Failed to instantiate TabBarViewController.")
            return
        }
        print("TabBarViewController instantiated successfully.")

        // Находим ProfileViewController в массиве viewControllers таб-бара
        if let profileViewController = tabBarController.viewControllers?.first(where: { $0 is ProfileViewController }) as? ProfileViewController {
            print("Found ProfileViewController within TabBarViewController.")
            profileViewController.profile = self.profile
            print("Profile data passed to ProfileViewController.")
        } else {
            print("Failed to find ProfileViewController within TabBarViewController.")
        }

        // Устанавливаем TabBarController как корневой контроллер окна
        guard let window = UIApplication.shared.windows.first else {
            print("Failed to access main window.")
            return
        }
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        print("TabBarViewController set as root view controller.")

        // Добавляем анимацию перехода
        UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromRight, animations: nil) { _ in
            print("Transition animation to TabBarViewController completed.")
        }
    }
    
    
        
    
    private func handleError(_ error: Error) {
           // Обработка ошибки, например, показываем сообщение пользователю
           print("Ошибка при получении данных профиля: \(error.localizedDescription)")
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

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            UIBlockingProgressHUD.show()
            OAuth2Service.shared.fetchOAuthToken1(code: code) { result in
                switch result {
                case .success(let token):
                    print("Token successfully fetched: \(token)")
                    DispatchQueue.main.async {
                        self.switchToTabBarController()
                    }
                case .failure(let error):
                    print("Failed to fetch token: \(error.localizedDescription)")
                }
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
}

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    private var profileService: ProfileService = ProfileService.shared
    private var profile: Profile?
    private var username: String?
    private var didAuthenticateOnce = false
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Сценарий "пользователь уже авторизован"
        if let token = oauth2TokenStorage.token {
            if profile == nil {
                fetchProfileAndAvatar { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            self?.switchToTabBarController()
                        case .failure(let error):
                            print("Error fetching profile and avatar: \(error.localizedDescription)")
                            self?.handleError(error)
                        }
                    }
                }
            }
        } else {
            showAuthenticationScreen()
            print("Token not found, starting authentication.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func fetchProfileAndAvatar(completion: @escaping (Result<Profile, Error>) -> Void) {
        print("Fetching profile and avatar...")
        profileService.fetchProfile { [weak self] result in
            switch result {
            case .success(let profile):
                self?.profile = profile
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { imageResult in
                    switch imageResult {
                    case .success(let avatarURL):
                        print("Fetched avatar URL: \(avatarURL)")
                        //Здесь была отправка уведомления
                        completion(.success(profile))
                    case .failure(let error):
                        print("Failed to fetch avatar URL: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func switchToTabBarController() {
        print("Switching to tabBar controller.")
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        // Загружаем CustomTabBarController из Storyboard и устанавливаем profile
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        if let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as? CustomTabBarController {
            tabBarController.profile = profile
            
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
                window.rootViewController = tabBarController
            }, completion: nil)
            print("CustomTabBarController успешно инициализирован")
        } else {
            print("Ошибка: не удалось инициализировать CustomTabBarController")
        }
    }
    
    private func handleError(_ error: Error) {
        // Обработка ошибки, например, показываем сообщение пользователю
        print("Ошибка при получении данных профиля: \(error.localizedDescription)")
    }
    
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
            OAuth2Service.shared.fetchOAuthToken(code: code) { result in
                switch result {
                case .success:
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

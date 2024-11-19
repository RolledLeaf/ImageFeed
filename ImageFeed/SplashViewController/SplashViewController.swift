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
        
        guard let token = oauth2TokenStorage.token else {
                showAuthenticationScreen()
                return
            }
            
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
            } else {
                print("Profile is already loaded.")
                switchToTabBarController()
            }
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
        guard !didAuthenticateOnce else { return }
        didAuthenticateOnce = true
        fetchProfileAndAvatar { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.switchToTabBarController()
                    case .failure(let error):
                        print("Error fetching profile and avatar after authentication: \(error.localizedDescription)")
                        self?.handleError(error)
                    }
                }
            }
        }
    
    
    private func fetchProfileAndAvatar(completion: @escaping (Result<Profile, Error>) -> Void) {
        profileService.fetchProfile { [weak self] result in
            switch result {
            case .success(let profile):
                self?.profile = profile
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { imageResult in
                    switch imageResult {
                    case .success(let avatarURL):
                        print("Fetched avatar URL: \(avatarURL)")
                        NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: nil, userInfo: ["URL": avatarURL])
                        print("Notification posted")
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
    
    private func fetchProfileData(_ token: String) {
        print("Starting to fetch profile data...")
        profileService.fetchProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    print("Profile successfully fetched: \(profile)")
                    self?.profile = profile
                    self?.switchToTabBarController() // Переход к TabBarController здесь
                    
                case .failure(let error):
                    print("Error fetching profile: \(error.localizedDescription)")
                    self?.handleError(error)
                }
            }
        }
    }
    
    
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        // Загружаем TabBarController из Storyboard и устанавливаем profile
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

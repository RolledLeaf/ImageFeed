import UIKit

final class ProfileViewController: UIViewController {
    
    private let profilePhotoView = UIImageView()
    private let profileNameLabel = UILabel()
    private let profileIDLabel = UILabel()
    private let profileDescriptionLabel = UILabel()
    private let logoutButton = UIButton()
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    var profile: Profile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInitialUI()
        loadProfile()
    }
   
  
    
    private func loadProfile() {
        ProfileService.shared.fetchProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self?.updateUI(with: profile)
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }

    private func updateUI(with profile: Profile) {
        profileNameLabel.text = profile.name
        profileIDLabel.text = "@\(profile.username)"
        profileDescriptionLabel.text = profile.bio

        // Загрузка URL аватара
        ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let avatarURL):
                    // Метод для загрузки изображения из URL в avatarImageView
                    self?.profilePhotoView.loadImage(from: avatarURL)
                case .failure(let error):
                    print("Failed to fetch profile image URL: \(error)")
                }
            }
        }
    }
    
    private func showError(_ error: Error) {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    
    private func configureLabel(_ label: UILabel, text: String, fontSize: CGFloat, weight: UIFont.Weight, color: Colors) {
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.textColor = UIColor(named: color.rawValue)
    }
    
    private func setupInitialUI() {
        let uiElements = [profilePhotoView, profileNameLabel, profileIDLabel, profileDescriptionLabel, logoutButton]
        uiElements.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        profilePhotoView.image = UIImage(named: "Photo")
        configureLabel(profileNameLabel, text: profile?.name ?? "T", fontSize: 23, weight: .bold, color: .nameColor)
        configureLabel(profileIDLabel, text: "@ekaterina_nov", fontSize: 13, weight: .regular, color: .idColor)
        configureLabel(profileDescriptionLabel, text: "Hello, world!", fontSize: 13, weight: .regular, color: .nameColor)
        logoutButton.setImage(UIImage(systemName: "ipad.and.arrow.forward"), for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        logoutButton.tintColor = .logoutRed
        logoutButton.layer.cornerRadius = 0
    
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Констрейнты для фото профиля
            profilePhotoView.heightAnchor.constraint(equalToConstant: 70),
            profilePhotoView.widthAnchor.constraint(equalToConstant: 70),
            profilePhotoView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35),
            profilePhotoView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            // Констрейнты для имени профиля
            profileNameLabel.topAnchor.constraint(equalTo: profilePhotoView.bottomAnchor, constant: 8),
            profileNameLabel.leadingAnchor.constraint(equalTo: profilePhotoView.leadingAnchor),
            
            // Констрейнты для ID профиля
            profileIDLabel.topAnchor.constraint(equalTo: profileNameLabel.bottomAnchor, constant: 8),
            profileIDLabel.leadingAnchor.constraint(equalTo: profilePhotoView.leadingAnchor),
            
            // Констрейнты для описания профиля
            profileDescriptionLabel.topAnchor.constraint(equalTo: profileIDLabel.bottomAnchor, constant: 8),
            profileDescriptionLabel.leadingAnchor.constraint(equalTo: profilePhotoView.leadingAnchor),
            
            // Констрейнты для кнопки выхода
            logoutButton.heightAnchor.constraint(equalToConstant: 24),
            logoutButton.widthAnchor.constraint(equalToConstant: 24),
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 55),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }
    
    @objc func logoutButtonTapped() {
        oauth2TokenStorage.clearToken()
        oauth2TokenStorage.clearCookies()
        switchToAuthScreen()
    }
    
    private func switchToAuthScreen() {
        guard let window = UIApplication.shared.windows.first else { return }
        
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
        window.makeKeyAndVisible()
        
        // Добавляем анимацию перехода
        UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
    }
}

extension UIImageView {
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, error == nil, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }.resume()
    }
}

import UIKit
import Kingfisher
final class ProfileViewController: UIViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupNotificationObserver()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private let profilePhotoView = UIImageView()
    private let profileNameLabel = UILabel()
    private let profileIDLabel = UILabel()
    private let profileDescriptionLabel = UILabel()
    private let logoutButton = UIButton()
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private let avatarGradientLayer = CAGradientLayer()
    private let nameGradientLayer = CAGradientLayer()
    private let idGradientLayer = CAGradientLayer()
    private let descriptionGradientLayer = CAGradientLayer()
    
    private var isObserverAdded = false
    
    var profile: Profile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInitialUI()
        addGradientAnimationToLabels()
        addAvatarGradientAnimation()
        loadProfile()
        
        if let avatarURL = ProfileImageService.shared.avatarURL,// 16
           let url = URL(string: avatarURL) {
            print("Avatar URL already available: \(avatarURL)")
            updateAvatarImage(with: url)
        }
    }
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateAvatar(_:)),
            name: ProfileImageService.didChangeNotification,
            object: nil
        )
        print("Observer added in init")
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("Observer removed in deinit")
    }
    
    
    private func addAvatarGradientAnimation() {
        print("avatar gradient animation started")
        // Настройка градиента
        avatarGradientLayer.colors = [
            UIColor(named: "GradientGreyColor1")?.cgColor ?? UIColor.systemGray.cgColor,
            UIColor(named: "GradientGreyColor2")?.cgColor ?? UIColor.systemGray.cgColor,
            UIColor(named: "GradientGreyColor3")?.cgColor ?? UIColor.systemGray.cgColor
        ]
        avatarGradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        avatarGradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        avatarGradientLayer.frame = profilePhotoView.bounds
        avatarGradientLayer.cornerRadius = 35
        avatarGradientLayer.masksToBounds = true
        
        profilePhotoView.layer.addSublayer(avatarGradientLayer)
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.duration = 0.75
        animation.fromValue = [0, 0.1, 0.3]
        animation.toValue = [0, 0.8, 1]
        animation.repeatCount = .infinity
        
        avatarGradientLayer.add(animation, forKey: "locationsChange")
    }
    
    private func removeAvatarGradientAnimation() {
        print("avatar gradient animation stopped")
        avatarGradientLayer.removeAllAnimations()
        avatarGradientLayer.removeFromSuperlayer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nameGradientLayer.frame = profileNameLabel.bounds
        idGradientLayer.frame = profileIDLabel.bounds
        descriptionGradientLayer.frame = profileDescriptionLabel.bounds
        avatarGradientLayer.frame = profilePhotoView.bounds
    }
    
    private func configureGradientLayer(_ gradientLayer: CAGradientLayer, for view: UIView) {
        gradientLayer.colors = [
            UIColor(named: "GradientGreyColor1")?.cgColor ?? UIColor.systemGray.cgColor,
            UIColor(named: "GradientGreyColor2")?.cgColor ?? UIColor.systemGray.cgColor,
            UIColor(named: "GradientGreyColor3")?.cgColor ?? UIColor.systemGray.cgColor
        ]
        let gradientPadding: CGFloat = 8
        
        let adjustedFrame = profileIDLabel.bounds.insetBy(dx: -gradientPadding, dy: -gradientPadding)
        gradientLayer.frame = adjustedFrame
        gradientLayer.cornerRadius = profileIDLabel.layer.cornerRadius + gradientPadding
        profileIDLabel.layer.addSublayer(gradientLayer)
        
        gradientLayer.cornerRadius = profileDescriptionLabel.layer.cornerRadius + gradientPadding
        profileDescriptionLabel.layer.addSublayer(gradientLayer)
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        view.layer.addSublayer(gradientLayer)
    }
    
    private func startGradientAnimation(for layer: CAGradientLayer) {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0, 0.5, 1]
        animation.toValue = [-0.2, 0.3, 1.2]
        animation.duration = 0.5
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: "loadingAnimation")
        print("labels gradient animation  started")
    }
    
    private func addGradientAnimationToLabels() {
        configureGradientLayer(nameGradientLayer, for: profileNameLabel)
        configureGradientLayer(idGradientLayer, for: profileIDLabel)
        configureGradientLayer(descriptionGradientLayer, for: profileDescriptionLabel)
        
        startGradientAnimation(for: nameGradientLayer)
        startGradientAnimation(for: idGradientLayer)
        startGradientAnimation(for: descriptionGradientLayer)
    }
    
    private func stopGradientAnimation(for layer: CAGradientLayer) {
        print("labels gradient animation stopped")
        layer.removeAllAnimations()
        layer.removeFromSuperlayer()
    }
    
    private func updateAvatarImage(with url: URL) {
        print("update Avatar Image called.")
        DispatchQueue.main.async {
            self.profilePhotoView.kf.setImage(with: url,
                                              options: [
                                                .transition(.fade(0.2)),
                                                .cacheOriginalImage
                                              ],
                                              completionHandler: { result in
                switch result {
                case .success:
                    print("Avatar image loaded successfully")
                    self.removeAvatarGradientAnimation()
                case .failure(let error):
                    print("Failed to load avatar image: \(error.localizedDescription)")
                }
            })
        }
    }
    
    @objc private func updateAvatar(_ notification: Notification) {
        print("updateAvatar called.")
        guard let userInfo = notification.userInfo,
              let avatarURLString = userInfo["URL"] as? String,
              let avatarURL = URL(string: avatarURLString) else {
            print("Failed to retrieve avatar URL from notification.")
            return
        }
        
        print("Received avatar URL in notification: \(avatarURLString)")
        
        DispatchQueue.main.async {
            self.profilePhotoView.kf.setImage(with: avatarURL,
                                              options: [
                                                .transition(.fade(0.2)),
                                                .cacheOriginalImage
                                              ],
                                              completionHandler: { result in
                switch result {
                case .success:
                    print("Avatar image loaded successfully")
                    
                case .failure(let error):
                    print("Failed to load avatar image: \(error.localizedDescription)")
                }
            }
            )
        }
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
        
        stopGradientAnimation(for: nameGradientLayer)
        stopGradientAnimation(for: idGradientLayer)
        stopGradientAnimation(for: descriptionGradientLayer)
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
        view.backgroundColor = UIColor(named: "Background color #1A1B22")
        
        profilePhotoView.clipsToBounds = true
        profilePhotoView.layer.cornerRadius = 35
        profilePhotoView.contentMode = .scaleAspectFill
        
        let uiElements = [profilePhotoView, profileNameLabel, profileIDLabel, profileDescriptionLabel, logoutButton]
        uiElements.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        configureLabel(profileNameLabel, text:  "User name", fontSize: 23, weight: .bold, color: .nameColor)
        configureLabel(profileIDLabel, text: "User ID", fontSize: 13, weight: .regular, color: .idColor)
        configureLabel(profileDescriptionLabel, text: "Bio", fontSize: 13, weight: .regular, color: .nameColor)
        logoutButton.setImage(UIImage(systemName: "ipad.and.arrow.forward"), for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        logoutButton.tintColor = .logoutRed
        logoutButton.layer.cornerRadius = 0
        setupConstraints()
        print("Initial UI setup complete")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Констрейнты для фото профиля
            profilePhotoView.heightAnchor.constraint(equalToConstant: 70),
            profilePhotoView.widthAnchor.constraint(equalToConstant: 70),
            profilePhotoView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35),
            profilePhotoView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            profileNameLabel.topAnchor.constraint(equalTo: profilePhotoView.bottomAnchor, constant: 8),
            profileNameLabel.leadingAnchor.constraint(equalTo: profilePhotoView.leadingAnchor),
            
            profileIDLabel.topAnchor.constraint(equalTo: profileNameLabel.bottomAnchor, constant: 8),
            profileIDLabel.leadingAnchor.constraint(equalTo: profilePhotoView.leadingAnchor),
            
            profileDescriptionLabel.topAnchor.constraint(equalTo: profileIDLabel.bottomAnchor, constant: 8),
            profileDescriptionLabel.leadingAnchor.constraint(equalTo: profilePhotoView.leadingAnchor),
            
            logoutButton.heightAnchor.constraint(equalToConstant: 24),
            logoutButton.widthAnchor.constraint(equalToConstant: 24),
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 55),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }
    
    @objc func logoutButtonTapped() {
        ProfileLogoutService.shared.logout()
    }
}



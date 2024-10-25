import UIKit

final class ProfileViewController: UIViewController {
    
    private let profilePhotoView = UIImageView()
    private let profileNameLabel = UILabel()
    private let profileIDLabel = UILabel()
    private let profileDescriptionLabel = UILabel()
    private let logoutButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let UIElements = [profilePhotoView, profileNameLabel, profileIDLabel, profileDescriptionLabel, logoutButton]
        UIElements.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        profilePhotoView.image = UIImage(named: "Photo")
        configureLabel(profileNameLabel, text: "Екатерина Новикова", fontSize: 23, weight: .bold, color: .nameColor)
        configureLabel(profileIDLabel, text: "@ekaterina_nov", fontSize: 13, weight: .regular, color: .idColor)
        configureLabel(profileDescriptionLabel, text: "Hello, world!", fontSize: 13, weight: .regular, color: .nameColor)
        logoutButton.setImage(UIImage(systemName: "ipad.and.arrow.forward"), for: .normal)
        logoutButton.tintColor = .logoutRed
        logoutButton.layer.cornerRadius = 0
        
        setupConstraints()
    }
    
    private func configureLabel(_ label: UILabel, text: String, fontSize: CGFloat, weight: UIFont.Weight, color: Colors) {
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.textColor = UIColor(named: color.rawValue)
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
}


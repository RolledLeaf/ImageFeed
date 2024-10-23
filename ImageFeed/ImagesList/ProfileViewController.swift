import UIKit

final class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let profilePhotoView = UIImageView()
        profilePhotoView.translatesAutoresizingMaskIntoConstraints = false
        profilePhotoView.image = UIImage(named: "Photo")
        view.addSubview(profilePhotoView)
        
        let profileNameLabel = UILabel()
        profileNameLabel.translatesAutoresizingMaskIntoConstraints = false
        profileNameLabel.text = "Екатерина Новикова"
        profileNameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        profileNameLabel.textColor = UIColor(named: "Name color #FFFFFFF")
        view.addSubview(profileNameLabel)
        
        let profileIDLabel = UILabel()
        profileIDLabel.translatesAutoresizingMaskIntoConstraints = false
        profileIDLabel.text = "@ekaterina_nov"
        profileIDLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        profileIDLabel.textColor = UIColor(named: "ID Color #AEAFB4")
        view.addSubview(profileIDLabel)
        
        let profileDescriptionLabel = UILabel()
        profileDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        profileDescriptionLabel.text = "Hello, world!"
        profileDescriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        profileDescriptionLabel.textColor = UIColor(named: "Name color #FFFFFFF")
        view.addSubview(profileDescriptionLabel)
        
        let logoutButton = UIButton()
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.setImage(UIImage(systemName: "ipad.and.arrow.forward"), for: .normal)
        logoutButton.tintColor = .logoutRed
        logoutButton.layer.cornerRadius = 0
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            profilePhotoView.heightAnchor.constraint(equalToConstant: 70),
            profilePhotoView.widthAnchor.constraint(equalToConstant: 70),
            profilePhotoView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35),
            profilePhotoView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)])
        profilePhotoView.layer.cornerRadius = 35
        profilePhotoView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            profileNameLabel.topAnchor.constraint(equalTo: profilePhotoView.bottomAnchor, constant: 8),
            profileNameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)])
        
        NSLayoutConstraint.activate([
            profileIDLabel.topAnchor.constraint(equalTo: profileNameLabel.bottomAnchor, constant: 8),
            profileIDLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)])
        
        NSLayoutConstraint.activate([
            profileDescriptionLabel.topAnchor.constraint(equalTo: profileIDLabel.bottomAnchor, constant: 8),
            profileDescriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)])
        
        NSLayoutConstraint.activate([
            logoutButton.heightAnchor.constraint(equalToConstant: 24),
            logoutButton.widthAnchor.constraint(equalToConstant: 24),
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 55),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)])
    }
    
}



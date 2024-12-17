import UIKit

final class CustomTabBarController: UITabBarController {
    
    var profile: Profile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
           guard let imagesListViewController = storyboard.instantiateViewController(
               withIdentifier: "ImagesListViewController"
           ) as? ImagesListViewController else {
               fatalError("Failed to instantiate ImagesListViewController")
           }
           
           // Создание service и presenter
           let imagesListService = ImagesListService()
           let imagesListPresenter = ImagesListPresenter(view: imagesListViewController, service: imagesListService)
           imagesListViewController.presenter = imagesListPresenter
        
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfileViewPresenter()
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController
        profileViewController.tabBarItem = UITabBarItem( title: "",
                                                         image: UIImage(named: "tab_profile_active"),
                                                         selectedImage: nil
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
    
    private func setupViewControllers() {
        guard let viewControllers = viewControllers else { return }
        
        for viewController in viewControllers {
            if let profileVC = viewController as? ProfileViewController {
                profileVC.profileVC = profile
            }
            if let navController = viewController as? UINavigationController,
               let profileVC = navController.viewControllers.first as? ProfileViewController {
                profileVC.profileVC = profile
            }
        }
    }
}


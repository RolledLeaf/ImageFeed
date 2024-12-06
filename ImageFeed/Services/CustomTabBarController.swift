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
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        )
        
        let profileViewController = ProfileViewController()
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
                profileVC.profile = profile
            }
            if let navController = viewController as? UINavigationController,
               let profileVC = navController.viewControllers.first as? ProfileViewController {
                profileVC.profile = profile
            }
        }
    }
}


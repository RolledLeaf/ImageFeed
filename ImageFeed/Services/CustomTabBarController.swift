import UIKit

final class CustomTabBarController: UITabBarController {
    var profile: Profile?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
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


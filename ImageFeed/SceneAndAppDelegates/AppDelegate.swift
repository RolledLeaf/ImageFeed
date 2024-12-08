import UIKit
import Kingfisher
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //Входная точка приложения
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func configureCache() {
        let cache = KingfisherManager.shared.cache
        cache.memoryStorage.config.totalCostLimit = 50 * 1024 * 1024 // 50 MB для памяти
        cache.diskStorage.config.sizeLimit = 100 * 1024 * 1024 // 100 MB для диска
        cache.diskStorage.config.expiration = .days(7) // Хранить 7 дней
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(          // 1
            name: "Main",
            sessionRole: connectingSceneSession.role
        )
        sceneConfiguration.delegateClass = SceneDelegate.self   // 2
        return sceneConfiguration
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}


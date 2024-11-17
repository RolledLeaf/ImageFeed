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
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}


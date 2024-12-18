import Foundation
import SwiftKeychainWrapper
import WebKit

final class ProfileLogoutService {
    
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    func logout() {
        
        let alertController = UIAlertController(
            title: "Пока-пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(title: "Да", style: .destructive) { _ in
            print("Logging out...")
            self.clearAllCookies{
                print("Cookies cleared")
            }
            self.clearToken()
            self.switchToAuthScreen()
        }
        
        let noAction = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
        
        // Установка accessibilityIdentifier для кнопок
        yesAction.accessibilityIdentifier = "LogoutYesButton"
        noAction.accessibilityIdentifier = "LogoutNoButton"
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }),
           let rootViewController = window.rootViewController {
            rootViewController.presentedViewController?.present(alertController, animated: true) ??
            rootViewController.present(alertController, animated: true)
        }
    }
    
    func clearToken() {
        OAuth2TokenStorage.shared.token = nil
        print("Token was cleared.")
    }
    
    func clearAllCookies(completion: @escaping () -> Void) {
        HTTPCookieStorage.shared.removeCookies(since: .distantPast)
        print("HTTPCookieStorage cookies cleared.")
        
        let webDataStore = WKWebsiteDataStore.default()
        webDataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in

            let dispatchGroup = DispatchGroup()
            
            for record in records {
                dispatchGroup.enter()
                webDataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: [record]) {
                    print("Removed data for \(record.displayName)")
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                print("WKWebsiteDataStore cookies cleared.")
                completion()
            }
        }
    }
    
    func switchToAuthScreen() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        
        let splashViewController = SplashViewController()
        UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromRight, animations: {
            window.rootViewController = splashViewController
        }, completion: nil)
        window.makeKeyAndVisible()
        print("Switched to auth screen")
    }
}

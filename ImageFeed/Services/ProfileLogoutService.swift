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
            self.clearAllCookies()
            self.clearToken()
            self.switchToAuthScreen()
        }
        
        let noAction = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
        
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
    
    func clearAllCookies() {
        let cookieStore = HTTPCookieStorage.shared
        cookieStore.cookies?.forEach { cookie in
            cookieStore.deleteCookie(cookie)
        }
        print("HTTPCookieStorage cookies cleared.")
        
        let webCookieStore = WKWebsiteDataStore.default().httpCookieStore
        webCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                webCookieStore.delete(cookie)
            }
            print("WKWebView cookies cleared.")
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

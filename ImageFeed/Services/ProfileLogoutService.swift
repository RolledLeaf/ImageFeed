import Foundation
import SwiftKeychainWrapper
import WebKit


final class ProfileLogoutService {
    
    static let shared = ProfileLogoutService()
    
    private init() { }
 
    func logout() {
        print("Logging out...")
        clearAllCookies()
        clearToken()
        switchToAuthScreen()
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

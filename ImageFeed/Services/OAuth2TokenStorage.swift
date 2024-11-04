import Foundation
import WebKit

//Упраление хранением токена
final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    init() {}
    
    private let tokenKey = "oauth_token"
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: tokenKey)
            print("Token saved: \(newValue ?? "")")
        }
        
    }
    
    func clearToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        print("Token removed: \(tokenKey)")
    }
    
    func clearCookies() {
        let cookieStore = WKWebsiteDataStore.default().httpCookieStore
        cookieStore.getAllCookies() { cookies in
            for cookie in cookies {
                cookieStore.delete(cookie)
            }
        }
    }
}

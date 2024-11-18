import Foundation
import WebKit
import SwiftKeychainWrapper

//Упраление хранением токена
final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    init() {}
    
    private let tokenKey = "oauth_token"
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue = newValue {
                let isSaved = KeychainWrapper.standard.set(newValue, forKey: tokenKey)
                if isSaved {
                    print("Token \(newValue) saved to keychain")
                } else {
                    print("Failed to save token to keychain")
                }
            } else {
                let isSaved = KeychainWrapper.standard.removeObject(forKey: tokenKey)
                if isSaved {
                    print("Token \(tokenKey) removed from keychain")
                } else {
                    print("Failed to remove token from keychain")
                }
                print("Token saved: \(newValue ?? "")")
            }
            
        }
    }
    
    func clearToken() {
        let isRevoved = KeychainWrapper.standard.removeObject(forKey: tokenKey)
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

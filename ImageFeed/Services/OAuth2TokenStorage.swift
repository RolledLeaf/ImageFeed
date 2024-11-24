import Foundation
import WebKit
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private let tokenKey = "oauth_token"

     init() {}

    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue = newValue {
                let success = KeychainWrapper.standard.set(newValue, forKey: tokenKey)
                print("Token saved successfully to keychain: \(success)")
            } else {
                let success = KeychainWrapper.standard.removeObject(forKey: tokenKey)
                print("Token removed from keychain successfully: \(success)")
            }
        }
    }

    func clearToken() {
        let success = KeychainWrapper.standard.removeObject(forKey: tokenKey)
        print("Token removed from keychain with clearToken method successfully: \(success)")
    }

    func clearCookies() {
        let cookieStore = WKWebsiteDataStore.default().httpCookieStore
        cookieStore.getAllCookies { cookies in
            for cookie in cookies {
                cookieStore.delete(cookie)
            }
        }
    }
}

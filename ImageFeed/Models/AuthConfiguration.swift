import Foundation

enum Constants {
    static let accessKey = "_P6dETzE_nGz7YsvDPWBgTLGJtrn772o8d2ssoOD89s"
    static let accessKey2 = "KS13lnqHxirbPbGJoo7FbksiM3EDn22g-loxp9_qOV0"
    static let secretKey = "sRSLufYVyuldHKQ_vaq9ej2MowExPykzJdM_mAra6Xc"
    static let secretKey2 = "8ZLjroqVzn1WaG8_Fkw5tB3QlvNOJcdLoQ0TrzPYZlQ"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public read_user write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let accessKey2: String
    let secretKey: String
    let secretKey2: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authorizeURLString: String
    
    init(accessKey: String, accessKey2: String, secretKey: String, secretKey2: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, authorizeURLString: String) {
        self.accessKey = accessKey
        self.accessKey2 = accessKey2
        self.secretKey = secretKey
        self.secretKey2 = accessKey2
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authorizeURLString = authorizeURLString
    }
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey, accessKey2: Constants.accessKey2,
                                 secretKey: Constants.secretKey, secretKey2: Constants.secretKey2,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 defaultBaseURL: Constants.defaultBaseURL,
                                 authorizeURLString: Constants.unsplashAuthorizeURLString)
        
    }
}



struct OAuthTokenResponseBody: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int?
    let scope: String?
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case scope
    }
}

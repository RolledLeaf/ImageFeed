import Foundation

final class ProfileImageService: ProfileImageServiceProtocol {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name("ProfileImageDidChange")
    
    private let urlSession: URLSession = .shared
    private(set) var avatarURL: String?
    
    private init() {}
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        print("Fetching profile image URL for username: \(username)")
        
        // Формирование URL и проверка на валидность
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            completion(.failure(ProfileImageServiceError.invalidURL))
            print("Invalid image URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(OAuth2TokenStorage.shared.token ?? "")", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        print("Sending request to URL: \(url)")
        
        urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userResult):
                print("Response received: \(userResult)")
                if let profileImageURL = userResult.profileImage?.small {
                    self?.avatarURL = profileImageURL
                    NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: self, userInfo: ["URL": profileImageURL])
                    print("Notification posted")
                    completion(.success(profileImageURL))
                } else {
                    print("No profile image URL found in response: \(userResult)")
                    completion(.failure(ProfileImageServiceError.noProfileImage))
                }
            case .failure(let error):
                print("Error fetching profile image URL: \(error.localizedDescription)")
                completion(.failure(error))
            }
        } .resume()
    }
}

struct UserResult: Codable {
    let profileImage: ProfileImage?
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}

enum ProfileImageServiceError: Error {
    case invalidURL
    case invalidResponse
    case noProfileImage
}

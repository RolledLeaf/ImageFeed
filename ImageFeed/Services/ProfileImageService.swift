import Foundation

final class ProfileImageService {
    
    static let shared = ProfileImageService()  // Синглтон
    static let didChangeNotification = Notification.Name("ProfileImageDidChange")
    
    private let urlSession: URLSession = .shared
    
    private(set) var avatarURL: String?  // Свойство для хранения URL изображения профиля
    
    private init() {}  // Приватный инициализатор для синглтона
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        print("Fetching profile image URL for username: \(username)")
        
        // Формирование URL и проверка на валидность
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            completion(.failure(ProfileImageServiceError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(OAuth2TokenStorage.shared.token ?? "")", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        print("Sending request to URL: \(url)")
        
        // Используем objectTask из расширения URLSession
        urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userResult):
                print("Response received: \(userResult)")
                if let profileImageURL = userResult.profileImage?.small {
                    self?.avatarURL = profileImageURL
                    print("Profile image URL fetched: \(profileImageURL)")
                    
                    // Отправка уведомления с URL
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: nil,
                        userInfo: ["URL": profileImageURL]
                    )
                    print("Notification sent with URL: \(profileImageURL)")
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


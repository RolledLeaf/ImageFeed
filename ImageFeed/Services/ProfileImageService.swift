import Foundation

final class ProfileImageService {
    
    static let shared = ProfileImageService()  // Синглтон
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private let urlSession: URLSession = .shared
    private let decoder = JSONDecoder()
    
    private(set) var avatarURL: String?  // Свойство для хранения URL изображения профиля
    
    private init() {}  // Приватный инициализатор для синглтона
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        print("Fetching profile image URL for username: \(username)")
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            completion(.failure(ProfileImageServiceError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(OAuth2TokenStorage.shared.token ?? "")", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        print("Sending request to URL: \(url)")
        
        urlSession.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching profile image URL: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response or status code")
                completion(.failure(ProfileImageServiceError.invalidResponse))
                return
            }
            
            do {
                let userResult = try self?.decoder.decode(UserResult.self, from: data)
                if let profileImageURL = userResult?.profileImage?.small {
                    self?.avatarURL = profileImageURL
                    print("Profile image URL fetched: \(profileImageURL)")
                    completion(.success(profileImageURL))
                    NotificationCenter.default                                     // 1
                        .post(                                                     // 2
                            name: ProfileImageService.didChangeNotification,       // 3
                            object: self,                                          // 4
                            userInfo: ["URL": profileImageURL])                    // 5
                } else {
                    print("No profile image URL found in response")
                    completion(.failure(ProfileImageServiceError.noProfileImage))
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
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

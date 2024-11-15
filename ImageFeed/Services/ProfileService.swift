import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private let urlSession: URLSession = .shared
    private var isRequestInProgress = false
    private var currentProfileTask: URLSessionTask?
    
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        // Проверяем, выполняется ли запрос
        if isRequestInProgress {
            currentProfileTask?.cancel()
            print("Previous request canceled.")
        }
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(ProfileServiceError.noToken))
            return
        }
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            completion(.failure(ProfileServiceError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("Making network request with token: \(token)")
        
        isRequestInProgress = true
        
        currentProfileTask = urlSession.objectTask(for: request) { [weak self] (result: Result<UserProfile, Error>) in
            self?.isRequestInProgress = false
            self?.currentProfileTask = nil
            
            switch result {
            case .success(let userProfile):
                let profile = Profile(
                    username: userProfile.username,
                    name: userProfile.name,
                    loginName: "@\(userProfile.username)",
                    bio: userProfile.bio
                )
                print("Successfully fetched profile: \(userProfile)")
                completion(.success(profile))
                
            case .failure(let error):
                if (error as NSError).code == NSURLErrorCancelled {
                    print("Request was canceled.")
                    return
                }
                completion(.failure(error))
            }
        }
        
        currentProfileTask?.resume()
    }
}

enum ProfileServiceError: Error {
    case noToken
    case invalidURL
    case invalidResponse
}

struct UserProfile: Decodable {
    let id: String
    let username: String
    let name: String
    let bio: String?
    let location: String?
}

struct Profile {
    let username: String      // Логин пользователя
    let name: String          // Полное имя пользователя
    let loginName: String     // Логин со знаком @
    let bio: String?          // Описание профиля
}

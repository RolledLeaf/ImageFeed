import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private let decoder = JSONDecoder()
    private let urlSession: URLSession = .shared
    private var isRequestInProgress = false
    private var currentProfileTask: URLSessionDataTask?
    
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        // Проверяем, выполняется ли запрос
        if isRequestInProgress {
            currentProfileTask?.cancel() // Отменяем предыдущий запрос, если идёт повторный
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
        
        isRequestInProgress = true // Устанавливаем флаг начала запроса
        currentProfileTask = urlSession.dataTask(with: request) { [weak self] data, response, error in
            // Сбрасываем флаг выполнения после завершения запроса
            self?.isRequestInProgress = false
            self?.currentProfileTask = nil
            
            if let error = error {
                if (error as NSError).code == NSURLErrorCancelled {
                    print("Request was canceled.")
                    return
                }
                completion(.failure(error))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(ProfileServiceError.invalidResponse))
                return
            }
            
            do {
                let userProfile = try self?.decoder.decode(UserProfile.self, from: data)
                if let userProfile = userProfile {
                    let profile = Profile(
                        username: userProfile.username,
                        name: userProfile.name,
                        loginName: "@\(userProfile.username)",
                        bio: userProfile.bio)
                    print("Successfully fetched profile: \(userProfile)")
                    completion(.success(profile))
                    print("User profile fetched successfully.")
                }
            } catch {
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

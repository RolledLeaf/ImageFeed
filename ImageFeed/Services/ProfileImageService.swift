import Foundation

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    private init() {}
    
    private var currentImageTask: URLSessionDataTask?
    private var isRequestInProgress = false
    private let requestQueue = DispatchQueue(label: "ProfileImageServiceQueue", attributes: .concurrent)
    
    private(set) var avatarURL: String?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        // Защита от гонки запросов
        requestQueue.async(flags: .barrier) {
            guard !self.isRequestInProgress else {
                print("Request already in progress")
                return
            }
            
            self.isRequestInProgress = true // Флаг о начале запроса

            let urlString = "https://api.unsplash.com/users/\(username)"
            
            guard let url = URL(string: urlString) else {
                completion(.failure(URLError(.badURL)))
                self.isRequestInProgress = false
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                defer {
                    self.isRequestInProgress = false // Сброс флага после завершения запроса
                }
                
                if let error = error {
                    print("Error fetching profile image: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    let responseError = NSError(domain: "ProfileImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                    completion(.failure(responseError))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                do {
                    // Декодирование данных
                    let userResult = try JSONDecoder().decode(UserResult.self, from: data)
                    if let avatarURL = userResult.profileImage?.small {
                        self.avatarURL = avatarURL
                        completion(.success(avatarURL))
                    } else {
                        completion(.failure(NSError(domain: "ProfileImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No avatar URL found"])))
                    }
                } catch {
                    print("Decoding error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            
            self.currentImageTask = task
            task.resume()
        }
    }
}

// Структура для декодирования ответа
struct UserResult: Codable {
    struct ProfileImage: Codable {
        let small: String
    }
    
    let profileImage: ProfileImage?
}

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private let urlSession: URLSession = .shared
    private var currentProfileTask: URLSessionTask?
    
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(ProfileServiceError.noToken))
            print("Token is nil.")
            return
        }
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            completion(.failure(ProfileServiceError.invalidURL))
            print("Invalid URL.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("Making network request with token: \(token)")
        
        currentProfileTask = urlSession.objectTask(for: request) { [weak self] (result: Result<UserProfile, Error>) in
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
                print("Error fetching profile: \(error.localizedDescription).")
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
    let username: String
    let name: String
    let loginName: String     
    let bio: String?
}

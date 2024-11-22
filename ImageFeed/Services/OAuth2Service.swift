import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private var currentAuthTask: URLSessionTask?
    private var isRequestInProgress = false
    
    private init() {}
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        print("Fetching OAuth token...")
        print("Access Key: \(Constants.accessKey)")
        print("Secret Key: \(Constants.secretKey)")
        print("Redirect URI: \(Constants.redirectURI)")
        print("Authorization Code: \(code)")
        
        if isRequestInProgress {
            if let currentCode = currentAuthTask?.originalRequest?.url?.query?.contains("code=\(code)"), currentCode {
                currentAuthTask?.cancel()
            } else {
                return
            }
        }
        
        isRequestInProgress = true
        
        let parameters: [String: String] = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            print("Invalid URL") // Логируем ошибку
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = parameters.percentEncoded()
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        
        currentAuthTask = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<TokenResponse, Error>) in
            guard let self = self else { return }
            defer { self.isRequestInProgress = false }
            
            switch result {
            case .success(let tokenResponse):
                let token = tokenResponse.accessToken
                OAuth2TokenStorage.shared.token = token
                print("Token successfully fetched: \(token)")
                completion(.success(token))
                
            case .failure(let error):
                print("Error fetching token: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        currentAuthTask?.resume()
    }
}

// Расширение для кодирования параметров
extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            "\(key)=\(value)"
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

// Структура для декодирования ответа
struct TokenResponse: Codable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
extension URLSession {
    func dataTask(with request: URLRequest, completion: @escaping (Result<(Data, URLResponse), Error>) -> Void) -> URLSessionDataTask {
        return dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data, let response = response else {
                    completion(.failure(NSError(domain: "DataError", code: -1, userInfo: nil)))
                    return
                }
                completion(.success((data, response)))
            }
        }
    }
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        
        let task = dataTask(with: request) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                
            case .success(let (data, _)):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        return task
    }
}

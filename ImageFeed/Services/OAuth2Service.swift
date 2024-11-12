import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
   
    private let decoder = JSONDecoder()
    
    private var currentAuthTask: URLSessionDataTask?
    private var isRequestInProgress = false
    
    private init() {} 
    
    func fetchOAuthToken1(code: String, completion: @escaping (Result<String, Error>) -> Void) {
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
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                    guard let self = self else { return }
                    defer { self.isRequestInProgress = false } 
            
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let responseError = NSError(domain: "ResponseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                print("Response error: \(responseError.localizedDescription)") // Логируем ошибку
                completion(.failure(responseError))
                return
            }
            
            // Обрабатываем успешный ответ или ошибки сервиса Unsplash
            if (200...299).contains(httpResponse.statusCode) {
                guard let data = data else {
                    print("No data received") // Логируем ошибку
                    completion(.failure(NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                do {
                    let tokenResponse = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
                    let token = tokenResponse.accessToken
                    // Сохраняем токен
                    OAuth2TokenStorage.shared.token = token
                    completion(.success(token))
                } catch {
                    print("Decoding error: \(error.localizedDescription)") // Логируем ошибку
                    completion(.failure(error))
                }
            } else {
                // Обработка ошибок от Unsplash
                do {
                    let errorResponse = try self.decoder.decode(ErrorResponse.self, from: data ?? Data())
                    print("Error from Unsplash: \(errorResponse.message)") // Логируем ошибку от Unsplash
                    completion(.failure(NSError(domain: "UnsplashError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])))
                } catch {
                    print("Failed to decode error response: \(error.localizedDescription)") // Логируем ошибку декодирования
                    completion(.failure(error))
                }
            }
        }.resume()
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

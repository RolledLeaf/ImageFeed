import UIKit
import Foundation



final class ImagesListService {
    
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    static let didStartLoadingNotification = Notification.Name("ImagesListServiceDidStartLoading")
    static let didFinishLoadingNotification = Notification.Name("ImagesListServiceDidFinishLoading")
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var isLoading = false
    private let token = OAuth2TokenStorage.shared.token
    private let baseURL = "https://api.unsplash.com"
    
    
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        print("Fetching next page of images...")
        guard !isLoading else { return }
        isLoading = true
        startLoadingNotification()
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let url = URL(string: "\(baseURL)/photos?page=\(nextPage)&per_page=10") else {
            print("Invalid URL")
            completion(.failure(NetworkError.invalidURL)) // Передаём ошибку
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(OAuth2TokenStorage.shared.token ?? "")", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            defer { self.isLoading = false }
            
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(error)) // Передаём ошибку
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("No data received.")
                completion(.failure(NetworkError.noData)) // Передаём ошибку
                return
            }
            
            do {
                let photoResults = try JSONDecoder().decode([PhotoResult].self, from: data)
                print("Fetched \(photoResults.count) photos.")
                let newPhotos = photoResults.map { Photo(from: $0) }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    self.stopLoadingNotification()
                    self.didChangeNotification()
                    completion(.success(newPhotos)) // Передаём успешный результат
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion(.failure(error)) // Передаём ошибку декодирования
            }
        }
        task.resume()
    }
    
    func updatePhotoLikeStatus(photoId: String, like: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        print("Attempting to update photo like status for photoId: \(photoId), like: \(like)")
        
        let action = like ? "like" : "like"
        guard let url = URL(string: "\(baseURL)/photos/\(photoId)/\(action)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = like ? "POST" : "DELETE"
        request.setValue("Bearer \(OAuth2TokenStorage.shared.token ?? "")", forHTTPHeaderField: "Authorization")
        print("Request configured with method: \(request.httpMethod ?? "") and headers: \(request.allHTTPHeaderFields ?? [:])")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("URLSession error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Received response with status code: \(httpResponse.statusCode)")
                if (200...299).contains(httpResponse.statusCode) {
                    print("Like/unlike operation succeeded. Response data: \(data?.count ?? 0) bytes")
                    completion(.success(()))
                } else {
                    print("Server error with status code: \(httpResponse.statusCode)")
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error"])))
                }
            } else {
                print("Invalid response format")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
            }
        }
        
        task.resume()
    }
    
    private func startLoadingNotification() {
        NotificationCenter.default.post(
            name: ImagesListService.didStartLoadingNotification,
            object: self
        )
    }
    
    private func stopLoadingNotification() {
        NotificationCenter.default.post(
            name: ImagesListService.didFinishLoadingNotification,
            object: self
        )
    }
    
    private func didChangeNotification() {
        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: self
        )
    }
    
    enum NetworkError: Error {
        case invalidURL
        case noData
        case decodingError
    }
}

struct Photo: Decodable {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: URL
    let largeImageURL: URL
    var isLiked: Bool
    var isLoading: Bool = true
}


struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, description, urls
        case createdAt = "created_at"
        case likedByUser = "liked_by_user"
    }
    
   
}

struct UrlsResult: Decodable {
    let thumb: URL
    let full: URL
}

extension Photo {
    init(from result: PhotoResult) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        self.createdAt = result.createdAt.flatMap { ISO8601DateFormatter.displayDateFormatter.date(from: $0) }
        self.welcomeDescription = result.description
        self.thumbImageURL = result.urls.thumb
        self.largeImageURL = result.urls.full
        self.isLiked = result.likedByUser
    }
}

extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var copy = self
        copy[index] = newValue
        return copy
    }
}

extension ISO8601DateFormatter {
    static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
}

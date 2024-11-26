import UIKit
import Foundation

final class ImagesListService {
    // MARK: - Static Properties
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    static let didStartLoadingNotification = Notification.Name("ImagesListServiceDidStartLoading")
    static let didFinishLoadingNotification = Notification.Name("ImagesListServiceDidFinishLoading")
    
    
    
    // MARK: - Private Properties
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var isLoading = false
    
    // MARK: - Methods
    func fetchPhotosNextPage() {
        print("Fetching next page of images...")
        guard !isLoading else { return }
        isLoading = true
        startLoadingNotification()
        
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)&per_page=10")!
        var request = URLRequest(url: url)
        request.addValue("Bearer \(OAuth2TokenStorage.shared.token ?? "")", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            defer { self.isLoading = false }
            
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data,
                  let responseString = String(data: data, encoding: .utf8)
                    
            else {
                print("No data received.")
                return
            }
            print("Response body: \(responseString)")
            
            do {
                let photoResults = try JSONDecoder().decode([PhotoResult].self, from: data)
                print("Fetched \(photoResults.count) photos.")
                let newPhotos = photoResults.map { Photo(from: $0) }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    
                    self.stopLoadingNotification()
                    
                    self.didChangeNotification()
                    
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
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
}


struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
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
    let thumb: String
    let full: String
}

// Преобразование из PhotoResult в Photo
extension Photo {
    init(from result: PhotoResult) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        self.createdAt = ISO8601DateFormatter().date(from: result.createdAt ?? "")
        self.welcomeDescription = result.description
        self.thumbImageURL = result.urls.thumb
        self.largeImageURL = result.urls.full
        self.isLiked = result.likedByUser
    }
}

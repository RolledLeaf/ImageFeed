import UIKit
import Foundation

final class ImagesListService {
    // MARK: - Static Properties
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    // MARK: - Private Properties
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var isLoading = false
    
    // MARK: - Methods
    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        isLoading = true
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)&per_page=10")!
        var request = URLRequest(url: url)
        request.addValue("Bearer YOUR_ACCESS_TOKEN", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            defer { self.isLoading = false }
            
            if let error = error {
                print("Failed to fetch photos: \(error.localizedDescription)")
                return
            }
            
            guard let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("Invalid response or data.")
                return
            }
            
            do {
                let photoResults = try JSONDecoder().decode([PhotoResult].self, from: data)
                let newPhotos = photoResults.map { Photo(from: $0) }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
            } catch {
                print("Failed to decode photos: \(error.localizedDescription)")
            }
        }
        task.resume()
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

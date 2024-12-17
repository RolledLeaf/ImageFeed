import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    func fetchPhotosNextPage()
    func likeButtonTapped(photoId: String, like: Bool, at indexPath: IndexPath)
    func onImageListServiceDidChange(_ notification: Notification)
    
    var photos: [Photo] { get }
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
   
    
    
    private var service = ImagesListService()
    var photos: [Photo] = []
    var view: ImagesListViewProtocol?
    var isLikeActionAllowed = true
    init(view: ImagesListViewController, service: ImagesListService) {
        self.view = view
        print("Presenter view is set: \(view)")
        self.service = service
    }
    
    func likeButtonTapped(photoId: String, like: Bool, at indexPath: IndexPath) {
        guard isLikeActionAllowed else { return }
        isLikeActionAllowed = false

        service.updatePhotoLikeStatus(photoId: photoId, like: like) { [weak self] result in
            guard let self = self else { return }

            // Разрешить следующую акцию спустя задержку
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.isLikeActionAllowed = true
            }

            // Сообщить представлению о результате
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self.photos[indexPath.row].isLiked = like
                    self.view?.updateRow(at: indexPath)
                case .failure(let error):
                    self.view?.showError(error)
                }
            }
        }
    }
    
    func onImageListServiceDidChange(_ notification: Notification) {
        
    }
    
    
  
    
    func fetchPhotosNextPage() {
        print("Calling service to fetch next page of photos")

            service.fetchPhotosNextPage { [weak self] result in
                switch result {
                case .success(let newPhotos):
                    print("Success case")
                    self?.photos.append(contentsOf: newPhotos)
                    print("Photos count: \(String(describing: self?.photos.count))")
                    self?.view?.reloadData()
                    print("ReloadData called on view")
                case .failure(let error):
                    print("Faile case")
                    self?.view?.showError(error)  // Показываем ошибку через метод в представлении
                }
            }
        }
}

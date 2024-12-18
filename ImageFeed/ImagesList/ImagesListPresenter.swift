import Foundation
import ProgressHUD

protocol ImagesListPresenterProtocol: AnyObject {
    func fetchPhotosNextPage()
    func likeButtonTapped(photoId: String, like: Bool, at indexPath: IndexPath)
    func onImagesListServiceDidChange(_ notification: Notification)
    
    var presenterDelegate: ImagesListPresenterDelegate? { get set }
    var photos: [Photo] { get set }
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var presenterDelegate: ImagesListPresenterDelegate?
    
    var service: ImagesListServiceProtocol
    var photos: [Photo] = []
    var view: ImagesListViewProtocol?
    var isLikeActionAllowed = true
    
    init(view: ImagesListViewProtocol, service: ImagesListServiceProtocol) {
        self.view = view
        self.service = service
        print("Presenter view is set: \(view)")
    }
    
    func likeButtonTapped(photoId: String, like: Bool, at indexPath: IndexPath) {
        guard isLikeActionAllowed else { return }
        isLikeActionAllowed = false
        view?.animateHUD()
        
        service.updatePhotoLikeStatus(photoId: photoId, like: like) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.isLikeActionAllowed = true
            }
            
            DispatchQueue.main.async {
                self.view?.dismissHUD()
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
    
    func onImagesListServiceDidChange(_ notification: Notification) {
        guard let newPhotos = notification.object as? [Photo] else { return }
        
        let oldCount = photos.count
        let newCount = newPhotos.count
        
        guard newCount > oldCount else { return }
        
        let newPhotosToAdd = Array(newPhotos[oldCount..<newCount])
        
        photos.append(contentsOf: newPhotosToAdd)
        
        presenterDelegate?.didUpdatePhotos(at: IndexSet(integersIn: oldCount..<newCount))
    }
    
    func fetchPhotosNextPage() {
        print("Calling service to fetch next page of photos")
        
        service.fetchPhotosNextPage { [weak self] result in
            switch result {
            case .success(let newPhotos):
                print("Photos fetched successfully")
                self?.photos.append(contentsOf: newPhotos)
                print("Photos count: \(String(describing: self?.photos.count))")
                self?.view?.reloadData()
                print("ReloadData called on view")
            case .failure(let error):
                print("Failed to fetch photos")
                self?.view?.showError(error)
            }
        }
    }
}

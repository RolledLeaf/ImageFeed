import Foundation

protocol ImagesListPresenterDelegate: AnyObject {
    func didUpdatePhotos(at indexSet: IndexSet)
}

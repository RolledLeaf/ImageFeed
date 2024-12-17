import UIKit
import Kingfisher
import ProgressHUD

protocol ImagesListViewProtocol: AnyObject {
    func reloadData()
    func showError(_ error: any Error)
    func updateRow(at indexPath: IndexPath)
}

final class ImagesListViewController: UIViewController, ImagesListViewProtocol {
    
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService()
    
    var presenter: ImagesListPresenterProtocol! = nil
    
    var photos: [Photo] = []
    var isLikeActionAllowed = true
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToStartLoadingNotification()
        subscribeToFinishLoadingNotification()
        setupTableView()
        subscribeToNotifications()
        presenter.fetchPhotosNextPage()
    }
    
    func likeButtonTapped(for cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let photo = presenter.photos[indexPath.row]
        let newLikeStatus = !photo.isLiked

        presenter.likeButtonTapped(photoId: photo.id, like: newLikeStatus, at: indexPath)
    }
    
    private func setupTableView() {
        print("Setting up table view")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    private func showLoading(_ isLoading: Bool) {
        if isLoading {
            ProgressHUD.animate()
        } else {
            ProgressHUD.dismiss()
        }
    }
    
    private func subscribeToNotifications() {
        guard presenter != nil else {
                assertionFailure("Presenter is not initialized")
                return
            }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onImagesListServiceDidChange),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
    }
    
    private func subscribeToFinishLoadingNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFinishLoading),
            name: ImagesListService.didFinishLoadingNotification,
            object: nil
        )
    }
    
    private func subscribeToStartLoadingNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStartLoading),
            name: ImagesListService.didStartLoadingNotification,
            object: nil
        )
    }
    
    @objc private func handleStartLoading() {
        showLoading(true)
    }
    
    @objc private func handleFinishLoading() {
        showLoading(false)
    }
    
    @objc private func onImagesListServiceDidChange(_ notification: Notification) {
        let newPhotos = imagesListService.photos
        let oldCount = photos.count
        let newCount = newPhotos.count
        
        
        guard newCount > oldCount else { return }
        
        let newPhotosToAdd = Array(newPhotos[oldCount..<newCount])
        
        photos.append(contentsOf: newPhotosToAdd)
        
        let indexPathsToAdd = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPathsToAdd, with: .automatic)
        }
    }
    
    func configCell(for cell: ImagesListCell, with photo: Photo) {
        let placeholder = UIImage(named: "downloadingImageMock")
        let url = photo.thumbImageURL
        
        cell.cellImageView.kf.indicatorType = .activity
        cell.cellImageView.kf.setImage(with: url, placeholder: placeholder) { [weak self, weak tableView] result in
            guard let self = self else { return }
            
            // Проверяем, что ячейка всё ещё отображается и indexPath актуален
            if let indexPath = tableView?.indexPath(for: cell),
               indexPath.row < self.photos.count {
                self.photos[indexPath.row].isLoading = false
                tableView?.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        cell.dateLabel.text = ISO8601DateFormatter.displayDateFormatter.string(from: photo.createdAt ?? Date())
        
        cell.setIsLiked(isActive: photo.isLiked)
        
        cell.likeButtonTappedAction = { [weak self] in
            guard let self = self else { return }
            let likeStatus = !photo.isLiked
            if let indexPath = tableView?.indexPath(for: cell) {
                self.presenter.likeButtonTapped(photoId: photo.id, like: likeStatus, at: indexPath)
            }
        }
        
        cell.roundCorners()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination or sender")
                return
            }
            let photo = photos[indexPath.row]
            viewController.imageURL = photo.largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func reloadData() {
            tableView.reloadData()
        print("reloading table data")
        }

    func updateRow(at indexPath: IndexPath) {
           tableView.reloadRows(at: [indexPath], with: .automatic)
       }

       func showError(_ error: Error) {
           print("Error: \(error.localizedDescription)")
           // Можно добавить показ Alert для пользователя
       }
    }

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows: \(presenter.photos.count)")
        return presenter.photos.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Configuring cell for row \(indexPath.row)")
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        let photo = presenter.photos[indexPath.row]
        configCell(for: cell, with: photo)
        return cell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            presenter.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
}

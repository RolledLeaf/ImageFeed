import UIKit
import Kingfisher
import ProgressHUD

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService()
    private var photos: [Photo] = []
    
    var isLikeActionAllowed = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToStartLoadingNotification()
        subscribeToFinishLoadingNotification()
        setupTableView()
        subscribeToNotifications()
        imagesListService.fetchPhotosNextPage()
    }
    
    func likeButtonTapped(photoId: String, like: Bool, at indexPath: IndexPath) {
        guard isLikeActionAllowed else { return }
        isLikeActionAllowed = false
        ProgressHUD.animate()
        
        imagesListService.updatePhotoLikeStatus(photoId: photoId, like: like) { result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.isLikeActionAllowed = true
            }
            
            DispatchQueue.main.async {
                ProgressHUD.dismiss()
                switch result {
                case .success():
                    self.photos[indexPath.row].isLiked = like
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                case .failure(let error):
                    print("Failed to update like status: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func setupTableView() {
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
        cell.cellImageView.kf.setImage(with: url, placeholder: placeholder) { [weak tableView] result in
            if let indexPath = tableView?.indexPath(for: cell),
               let visiblePaths = tableView?.indexPathsForVisibleRows,
               visiblePaths.contains(indexPath) {
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
                self.likeButtonTapped(photoId: photo.id, like: likeStatus, at: indexPath)
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
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        let photo = photos[indexPath.row]
        configCell(for: cell, with: photo)
        return cell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
}

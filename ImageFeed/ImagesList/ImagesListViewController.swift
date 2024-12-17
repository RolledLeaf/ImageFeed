import UIKit
import Kingfisher
import ProgressHUD

// MARK: - Protocols

protocol ImagesListViewProtocol: AnyObject {
    func reloadData()
    func showError(_ error: any Error)
    func updateRow(at indexPath: IndexPath)
}

// MARK: - View Controller

final class ImagesListViewController: UIViewController, ImagesListViewProtocol, ImagesListPresenterDelegate {
    
    // MARK: - Properties
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService()
    
    var presenter: ImagesListPresenterProtocol!
    var isLikeActionAllowed = true
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        subscribeToNotifications()
        presenter.fetchPhotosNextPage()
        presenter.presenterDelegate = self
    }
    
    // MARK: - Private Methods
    
    private func setupTableView() {
        print("Setting up table view")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    private func subscribeToNotifications() {
        subscribeToStartLoadingNotification()
        subscribeToFinishLoadingNotification()
    }
    
    private func subscribeToStartLoadingNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStartLoading),
            name: ImagesListService.didStartLoadingNotification,
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
    
    @objc private func handleStartLoading() {
        showLoading(true)
    }
    
    @objc private func handleFinishLoading() {
        showLoading(false)
    }
    
    private func showLoading(_ isLoading: Bool) {
        if isLoading {
            ProgressHUD.animate()
        } else {
            ProgressHUD.dismiss()
        }
    }
    
    // MARK: - Actions
    
    func likeButtonTapped(for cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let photo = presenter.photos[indexPath.row]
        let newLikeStatus = !photo.isLiked
        
        presenter.likeButtonTapped(photoId: photo.id, like: newLikeStatus, at: indexPath)
    }
    
    // MARK: - Configuring Cells
    
    func configCell(for cell: ImagesListCell, with photo: Photo) {
        let placeholder = UIImage(named: "downloadingImageMock")
        let url = photo.thumbImageURL
        
        cell.cellImageView.kf.indicatorType = .activity
        cell.cellImageView.kf.setImage(with: url, placeholder: placeholder) { [weak self, weak tableView] result in
            guard let self = self else { return }
            
            if let indexPath = tableView?.indexPath(for: cell),
               indexPath.row < presenter.photos.count {
                self.presenter.photos[indexPath.row].isLoading = false
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
    
    // MARK: - Segue Handling
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination or sender")
                return
            }
            let photo = presenter.photos[indexPath.row]
            viewController.imageURL = photo.largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - View Updates
    
    func reloadData() {
        tableView.reloadData()
        print("reloading table data")
    }
    
    func updateRow(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func showError(_ error: Error) {
        print("Error: \(error.localizedDescription)")
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    }
    
    // MARK: - ImagesListPresenterDelegate
    
    func didUpdatePhotos(at indexSet: IndexSet) {
        tableView.performBatchUpdates {
            tableView.beginUpdates()
            tableView.insertRows(at: indexSet.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        }
        tableView.endUpdates()
    }
}

// MARK: - UITableViewDataSource

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

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("Will display row: \(indexPath.row), Total photos: \(presenter.photos.count)")
        if indexPath.row == presenter.photos.count - 1 {
            print("Reached last visible row, fetching next page...")
            presenter.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
}

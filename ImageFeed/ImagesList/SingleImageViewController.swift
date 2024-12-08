import UIKit
import ProgressHUD

final class SingleImageViewController: UIViewController {
    var imageURL: URL?
    
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction private func didTapShareButton(_ sender: Any) {
        guard let image = imageURL else {
            return
        }
        
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        loadImage()
    }
    
    private func loadImage() {
        guard let imageURL = imageURL else { return }
        ProgressHUD.animate()
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: imageURL) { [weak self] result in
            switch result {
            case .success(let value):
                print("Image loaded successfully.")
                ProgressHUD.dismiss()
                self?.rescaleAndCenterImageInScrollView(image: value.image)
            case .failure(let error):
                ProgressHUD.dismiss()
                print("Failed to load image: \(error.localizedDescription)")
            }
        }
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale: CGFloat = 1
        let maxZoomScale: CGFloat = 1.25
        
        scrollView.minimumZoomScale = minZoomScale
        scrollView.maximumZoomScale = maxZoomScale
        view.layoutIfNeeded()
        
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        centerImage()
    }
    
    private func centerImage() {
        let visibleRectSize = scrollView.bounds.size
        let newContentSize = scrollView.contentSize
        let x = max((newContentSize.width - visibleRectSize.width) / 2, 0)
        let y = max((newContentSize.height - visibleRectSize.height) / 2, 0)
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}

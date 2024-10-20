import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
            
            // Если изображение есть, вызываем рескейл и центрирование
            if let image = image {
                rescaleAndCenterImageInScrollView(image: image)
            }
        }
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = image else {
            return
        }
        
        // массив с данными для передачи (в данном случае это изображение)
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        // Показываем ActivityViewController
        present(activityController, animated: true, completion: nil)
    }

    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Устанавливаем изображение и выполняем рескейл
        if let image = image {
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
        
        // Устанавливаем параметры масштабирования для UIScrollView
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    
    // Метод рескейла и центрирования изображения в UIScrollView
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
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
    
    // Центрирование изображения в scrollView
     func centerImage() {
        let visibleRectSize = scrollView.bounds.size
        let newContentSize = scrollView.contentSize
        let x = max((newContentSize.width - visibleRectSize.width) / 2, 0)
        let y = max((newContentSize.height - visibleRectSize.height) / 2, 0)
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}


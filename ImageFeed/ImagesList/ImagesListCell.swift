import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    
    private let gradientLayer = CAGradientLayer()
    
    var likeButtonTappedAction: (() -> Void)?
    
    private func setupGradientLayer() {
        gradientLayer.colors = [
            UIColor(named: "GradientGreyColor1")?.cgColor ?? UIColor.systemGray.cgColor,
            UIColor(named: "GradientGreyColor2")?.cgColor ?? UIColor.systemGray.cgColor,
            UIColor(named: "GradientGreyColor3")?.cgColor ?? UIColor.systemGray.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.isHidden = true
        contentView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = contentView.bounds
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGradientLayer()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopGradientAnimation()
    }
    
    func startGradientAnimation() {
        gradientLayer.isHidden = false
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0, 0.1, 0.3]
        animation.toValue = [0, 0.8, 1]
        animation.duration = 1.0
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        gradientLayer.add(animation, forKey: "locationsChange")
    }
    
    func stopGradientAnimation() {
        gradientLayer.isHidden = true
        gradientLayer.removeAllAnimations()
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        likeButtonTappedAction?()
    }
    
    func setIsLiked(isActive: Bool) {
        let buttonImageName = isActive ? "Active" : "No Active"
        likeButton.setImage(UIImage(named: buttonImageName), for: .normal)
    }
    
    func roundCorners() {
        cellImageView.layer.cornerRadius = 16
        cellImageView.layer.masksToBounds = true
    }
}

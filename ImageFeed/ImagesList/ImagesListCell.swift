import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    
    var likeButtonTappedAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        likeButtonTappedAction?()
    }
    
    func setIsLiked(isActive: Bool) {
        let buttonImageName = isActive ? "Active" : "No Active"
        likeButton.setImage(UIImage(named: buttonImageName), for: .normal)
        likeButton.accessibilityIdentifier =  "LikeButton"
        
    }
    
    func roundCorners() {
        cellImageView.layer.cornerRadius = 16
        cellImageView.layer.masksToBounds = true
    }
}

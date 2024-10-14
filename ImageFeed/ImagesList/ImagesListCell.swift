import UIKit

//Добавление идентификатора ячейки
final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    
    func configurationButton(isActive: Bool) {
        let buttonImageName = isActive ? "Active" : "No Active"
        likeButton.setImage(UIImage(named: buttonImageName), for: .normal)
    }
    
    func roundCorners() {
        cellImageView.layer.cornerRadius = 16
        cellImageView.layer.masksToBounds = true
    }
}


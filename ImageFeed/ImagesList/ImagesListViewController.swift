
import UIKit

class ImagesListViewController: UIViewController {

    
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
     let photosName: [String] = Array(0..<20).map{"\($0)"}

    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imageName = photosName[indexPath.row]
        cell.cellImageView.image = UIImage(named: imageName)
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        cell.dateLabel.text = dateFormatter.string(from: currentDate)
        
        let isActive = indexPath.row % 2 == 0
        cell.configurationButton(isActive: isActive)
        cell.roundCorners()
        }
    }



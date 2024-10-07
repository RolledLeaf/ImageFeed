
import UIKit

class ImagesListViewController: UIViewController {

    
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 200
        
    }

    func configCell(for cell: ImagesListCell) {
        
    }
}


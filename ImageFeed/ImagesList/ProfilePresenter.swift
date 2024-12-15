import Foundation

protocol ProfileViewPresenterProtocol: AnyObject {
    func logout()
    func loadProfile()
    var view: ProfileViewControllerProtocol? { get set}
    
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?
    
    
    func logout() {
        ProfileLogoutService.shared.logout()
    }
    
    func loadProfile() {
        ProfileService.shared.fetchProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    print("Loading profile success case")
                    self?.view?.updateUI(with: profile)
                    self?.view?.stopLoadingAnimation()
                case .failure(let error):
                    print("Loading profile failure case")
                    self?.view?.showError(error)
                }
            }
        }
    }
    
}

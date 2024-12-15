import Foundation

protocol ProfileViewPresenterProtocol: AnyObject {
    func logout()
    func loadProfile()
    func handleAvatarNotification(notification: Notification)
    func updateAvatarImage(with url: URL)
    var view: ProfileViewControllerProtocol? { get set}
    
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?
    
    
    func logout() {
        ProfileLogoutService.shared.logout()
    }
    
    func handleAvatarNotification(notification: Notification) {
           print("Avatar notification received.")
           guard let userInfo = notification.userInfo,
                 let avatarURLString = userInfo["URL"] as? String,
                 let avatarURL = URL(string: avatarURLString) else {
               print("Failed to retrieve avatar URL from notification.")
               return
           }
           
           print("Received avatar URL in notification: \(avatarURLString)")
           view?.updateAvatarImage(url: avatarURL)
       }
    
    func updateAvatarImage(with url: URL) {
        print("update Avatar Image called.")
        DispatchQueue.main.async {
            self.view?.updateAvatarImage(url: url)
        }
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

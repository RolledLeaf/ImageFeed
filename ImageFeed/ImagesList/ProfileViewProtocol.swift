import UIKit
protocol ProfileViewProtocol: AnyObject {
    func updateUI(with profile: Profile)
    func updateAvatarImage(with url: URL)
    func startAvatarLoadingAnimation()
    func stopAvatarLoadingAnimation()
    func showError(_ error: Error)
}

import Foundation

protocol ProfileViewPresenterProtocol: AnyObject {
    func viewDidLoad()
    func logout()
    func loadProfile()
    func loadAvatar(for username: String)
    func showError(_ error: Error)
    var profileView: ProfileViewProtocol? { get set}
}

final class ProfilePresenter: ProfileViewPresenterProtocol {
    
    // MARK: - Properties
    weak var profileView: ProfileViewProtocol?
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    
    // Инициализация презентера с зависимостями
    init(view: ProfileViewProtocol,
         profileService: ProfileServiceProtocol = ProfileService.shared,
         profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared) {
        self.profileView = view
        self.profileService = profileService
        self.profileImageService = profileImageService
    }
    
    // MARK: - ProfileViewPresenterProtocol Methods
    
    func viewDidLoad() {
        loadProfile()  // Вызываем метод для получения профиля
    }
    
    func loadProfile() {
        profileService.fetchProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self?.profileView?.updateUI(with: profile)
                    self?.loadAvatar(for: profile.username)  // Загружаем изображение профиля
                case .failure(let error):
                    self?.profileView?.showError(error)
                }
            }
        }
    }
    
    func loadAvatar(for username: String) {
        profileImageService.fetchProfileImageURL(username: username) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let imageURL):
                    let imageURLString = imageURL
                    if let imageURL = URL(string: imageURLString) {  // Преобразуем строку в URL
                        self?.profileView?.updateAvatarImage(with: imageURL)  // Передаем URL
                    } else {
                        self?.profileView?.showError(ProfileImageServiceError.invalidURL)  // Ошибка, если не удалось создать URL
                    }
                case .failure(let error):
                    self?.profileView?.showError(error)
                }
            }
        }
    }
    
    func showError(_ error: Error) {
           profileView?.showError(error)  // Перенаправляем ошибку на контроллер для отображения
       }
    
    func logout() {
        ProfileLogoutService.shared.logout()  // Выход из системы
    }
}

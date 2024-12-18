protocol ProfileImageServiceProtocol {
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void)
}

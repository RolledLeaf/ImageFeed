protocol ProfileServiceProtocol {
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void)
}

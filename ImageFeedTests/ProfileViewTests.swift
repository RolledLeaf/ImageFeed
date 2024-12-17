
import Foundation
import XCTest

class ProfileViewPresenterMock: ProfileViewPresenterProtocol {
    func logout() {
        didCallLogout = true
    }
    
    func loadProfile() {
        let mockProfile = Profile(username: "test_user", name: "Test User", loginName:"@test_user", bio: "Test Bio")
                view?.updateUI(with: mockProfile)
    }
    
    func handleAvatarNotification(notification: Notification) {
        didRecieveAvatarNotification = true
    }
    
    func updateAvatarImage(with url: URL) {
        didUpdatedAvatarImage = true
    }
    
    var view: (any ProfileViewControllerProtocol)?
    var didCallLogout = false
    var didUpdatedAvatarImage = false
    var didRecieveAvatarNotification = false
}

final class MockProfileView: ProfileViewControllerProtocol {
    
    var presenter: ProfileViewPresenterProtocol
    
    init(presenter: ProfileViewPresenterProtocol?) {
        self.presenter = presenter!
       }
    
    
    
    var didCallUpdateUI = false
    var didCallShowError = false
    var didCallUpdateAvatarImage = false
    
    func updateUI(with profile: Profile) {
        didCallUpdateUI = true
    }
    
    func showError(_ error: Error) {
        didCallShowError = true
    }
    
    func updateAvatarImage(url: URL) {
        didCallUpdateAvatarImage = true
    }
    
    func stopLoadingAnimation() { }
    
    func startAvatarAnimation() { }
}

@testable import ImageFeed

final class ProfileViewTests: XCTestCase {
    
    private var presenterMock: ProfileViewPresenterMock!
    private var profileViewController: ProfileViewController!
    
    override func setUp() {
        super.setUp()
        // Инициализация общих объектов
        presenterMock = ProfileViewPresenterMock()
        profileViewController = ProfileViewController()
        profileViewController.presenter = presenterMock
    }
    
    override func tearDown() {
        // Очистка после тестов
        presenterMock = nil
        profileViewController = nil
        super.tearDown()
    }
    
    func testLogoutCallsPresenterMethod() {
        // Act
        profileViewController.presenter.logout()
        
        // Assert
        XCTAssertTrue(presenterMock.didCallLogout, "Expected `logout()` method to be called, but it was not.")
    }
    
    func testLoadProfileUpdatesUI() {
        // Arrange
        let mockView = MockProfileView(presenter: presenterMock)
        presenterMock.view = mockView
        
        // Act
        presenterMock.loadProfile()
        
        // Assert
        XCTAssertTrue(mockView.didCallUpdateUI, "Expected `updateUI(with:)` to be called, but it was not.")
    }
    
    func testUpdateAvatarImage() {
        // Arrange
        let mockView = MockProfileView(presenter: presenterMock)
        presenterMock.view = mockView
        let url = URL(string: "https://example.com/avatar.jpg")!
        
        // Act
        presenterMock.updateAvatarImage(with: url)
        
        // Assert
        XCTAssertTrue(presenterMock.didUpdatedAvatarImage, "Expected `updateAvatarImage(with:)` to be called, but it was not.")
    }
   
    func testHandleAvatarNotification() {
        // Arrange
        let notification = Notification(name: Notification.Name("AvatarUpdated"))
        
        // Act
        presenterMock.handleAvatarNotification(notification: notification)
        
        // Assert
        XCTAssertTrue(presenterMock.didRecieveAvatarNotification, "Expected `handleAvatarNotification(notification:)` to be called, but it was not.")
    }
    
    func testShowErrorIsCalled() {
        // Arrange
        let mockView = MockProfileView(presenter: presenterMock)
        presenterMock.view = mockView
        let error = NSError(domain: "TestError", code: 0, userInfo: nil)
        
        // Act
        mockView.showError(error)
        
        // Assert
        XCTAssertTrue(mockView.didCallShowError, "Expected `showError(_:)` to be called, but it was not.")
    }
    
}

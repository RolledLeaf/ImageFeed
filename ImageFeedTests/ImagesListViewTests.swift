


import Foundation
import XCTest
@testable import ImageFeed

class MockImagesListPresenter: ImagesListPresenterProtocol {
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    func likeButtonTapped(photoId: String, like: Bool, at indexPath: IndexPath) {
        likeButtonTappedCalled = true
        likeButtonTappedArguments = (photoId, like, indexPath)
    }
    
    func onImagesListServiceDidChange(_ notification: Notification) {
       
    }
    
    var fetchPhotosNextPageCalled = false
    var likeButtonTappedCalled = false
    var likeButtonTappedArguments: (photoId: String, like: Bool, indexPath: IndexPath)?
    
    var presenterDelegate: ImagesListPresenterDelegate?
    var photos: [Photo] = []
    
}

class MockImagesListView: ImagesListViewProtocol {
    var reloadDataCalled = false
    var updateRowCalled = false
    var updateRowIndexPath: IndexPath?
    var showErrorCalled = false
    var showErrorMessage: String?
    var updateRow: ((IndexPath) -> Void)?
    var showError: ((Error) -> Void)?
    
    func reloadData() {
        reloadDataCalled = true
    }
    
    func updateRow(at indexPath: IndexPath) {
        updateRowCalled = true
        updateRowIndexPath = indexPath
        updateRow?(indexPath)
    }
    
    func showError(_ error: Error) {
        showErrorCalled = true
        showErrorMessage = error.localizedDescription
        showError?(error)
    }
}

class MockImagesListService: ImagesListServiceProtocol {
    var shouldFail = false
    var mockPhotos: [Photo] = []
    var mockUpdateLikeSuccess: Bool = true
    var mockError: Error?

    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        if let error = mockError {
            completion(.failure(error))
        } else {
            completion(.success(mockPhotos))
        }
    }

    func updatePhotoLikeStatus(photoId: String, like: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        if mockUpdateLikeSuccess {
            completion(.success(()))
        } else if let error = mockError {
            completion(.failure(error))
        }
    }
}

final class ImagesListPresenterTests: XCTestCase {
    
    
    func testFetchPhotosNextPageCallsReloadData() {
        // Arrange
        let mockView = MockImagesListView()
        let mockService = MockImagesListService()
        let presenter = ImagesListPresenter(view: mockView, service: mockService)
        
        mockService.mockPhotos = [Photo(id: "1", isLiked: false), Photo(id: "2", isLiked: true)]
        
        // Act
        presenter.fetchPhotosNextPage()
        
        
        // Assert
        XCTAssertTrue(mockView.reloadDataCalled, "reloadData() should be called on the view after fetching photos")
    }
    
    func testLikeButtonTappedUpdatesRowOnSuccess() {
        // Arrange
        let mockView = MockImagesListView()
        let mockService = MockImagesListService()
        let presenter = ImagesListPresenter(view: mockView, service: mockService)
        
        let expectation = XCTestExpectation(description: "Wait for likeButtonTapped completion")
        let indexPath = IndexPath(row: 0, section: 0)
        mockService.mockUpdateLikeSuccess = true
        presenter.photos = [
            Photo(id: "1", isLiked: false), Photo(id: "2", isLiked: true)
        ]
        
        // Act
        presenter.likeButtonTapped(photoId: "1", like: true, at: indexPath)
        
        // Assert
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertTrue(mockView.updateRowCalled, "updateRow(at:) should be called on the view when like is updated successfully")
            XCTAssertEqual(mockView.updateRowIndexPath, indexPath, "updateRow(at:) should be called with the correct indexPath")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }

    func testLikeButtonTappedShowsErrorOnFailure() {
        // Arrange
        let mockView = MockImagesListView()
        let mockService = MockImagesListService()
        let presenter = ImagesListPresenter(view: mockView, service: mockService)
        
        let expectation = XCTestExpectation(description: "Wait for likeButtonTapped completion")
        let indexPath = IndexPath(row: 0, section: 0)
        mockService.mockUpdateLikeSuccess = false
        mockService.mockError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Test Error"])
        presenter.photos = [
            Photo(id: "1", isLiked: false), Photo(id: "2", isLiked: true)
        ]
        
        // Act
        presenter.likeButtonTapped(photoId: "1", like: true, at: indexPath)
        
        // Assert
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertTrue(mockView.showErrorCalled, "showError(_:) should be called on the view when like update fails")
            XCTAssertEqual(mockView.showErrorMessage, "Test Error", "showError(_:) should be called with the correct error message")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}

final class ImagesListViewControllerTests: XCTestCase {
    
    func testReloadDataCalled() {
        // Arrange
        let mockView = MockImagesListView()
        let mockService = MockImagesListService()
        let presenter = ImagesListPresenter(view: mockView, service: mockService)
        
        // Act
        presenter.fetchPhotosNextPage()  // Это вызывает reloadData() на view
        
        // Assert
        XCTAssertTrue(mockView.reloadDataCalled, "reloadData() should be called on the view when fetchPhotosNextPage() is called")
    }
    
    func testUpdateRowCalled() {
        // Arrange
        let mockView = MockImagesListView()
        let mockService = MockImagesListService()
        let presenter = ImagesListPresenter(view: mockView, service: mockService)
        
        let indexPath = IndexPath(row: 0, section: 0)
        mockService.mockUpdateLikeSuccess = true  // Устанавливаем успешный результат для симуляции изменения лайка
        presenter.photos = [Photo(id: "1", isLiked: false)]
        
        // Ожидаем, что updateRow будет вызван
        let expectation = self.expectation(description: "updateRow called")
        
        // Заменяем updateRow на моковый метод, который будет выполнять ожидание
        mockView.updateRow = { indexPath in
            XCTAssertEqual(indexPath, indexPath, "updateRow(at:) should be called with the correct indexPath")
            expectation.fulfill()  // Успешно выполняем ожидание
        }
        
        // Act
        presenter.likeButtonTapped(photoId: "1", like: true, at: indexPath)  // Это должно вызвать updateRow(at:) на view
        
        // Assert
        waitForExpectations(timeout: 1.0, handler: nil)  // Ожидаем, пока не будет вызвано ожидание
        XCTAssertTrue(mockView.updateRowCalled, "updateRow(at:) should be called on the view when like is updated successfully")
        XCTAssertEqual(mockView.updateRowIndexPath, indexPath, "updateRow(at:) should be called with the correct indexPath")
    }
    
    func testShowErrorCalledOnFailure() {
        // Arrange
        let mockView = MockImagesListView()
        let mockService = MockImagesListService()
        let presenter = ImagesListPresenter(view: mockView, service: mockService)
        
        let indexPath = IndexPath(row: 0, section: 0)
        mockService.mockUpdateLikeSuccess = false
        mockService.mockError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Test Error"])
        presenter.photos = [Photo(id: "1", isLiked: false)]
        
        // Ожидаем, что showError будет вызван
        let expectation = self.expectation(description: "showError called")
        
        // Назначаем замыкание для showError
        mockView.showError = { error in
            XCTAssertEqual(error.localizedDescription, "Test Error", "showError(_:) should be called with the correct error message")
            expectation.fulfill()  // Ожидаем вызова замыкания
        }
        
        // Act
        presenter.likeButtonTapped(photoId: "1", like: true, at: indexPath)
        
        // Assert
        waitForExpectations(timeout: 1.0, handler: nil)  // Ожидаем завершения асинхронного вызова
        XCTAssertTrue(mockView.showErrorCalled, "showError(_:) should be called on the view when like update fails")
        XCTAssertEqual(mockView.showErrorMessage, "Test Error", "showError(_:) should be called with the correct error message")
    }
    
}

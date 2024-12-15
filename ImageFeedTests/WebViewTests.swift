import XCTest

class WebViewPresenterMock: WebViewPresenterProtocol {
    weak var webView: WebViewViewControllerProtocol?
    var isViewDidLoadCalled = false

    func viewDidLoad() {
        isViewDidLoadCalled = true
    }

    func loadAuthView() { }
    func didUpdateProgressValue(_ newValue: Double) { }
    func code(from url: URL) -> String? { return nil }
}

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var webViewPresenter: (any ImageFeed.WebViewPresenterProtocol)?
    
    var presenter: ImageFeed.WebViewPresenterProtocol?

    var loadRequestCalled: Bool = false

    func load(request: URLRequest) {
        loadRequestCalled = true
    }

    func setProgressValue(_ newValue: Float) {

    }

    func setProgressHidden(_ isHidden: Bool) {

    }
}


@testable import ImageFeed

final class WebViewViewControllerTests: XCTestCase {
    var viewController: WebViewViewController!
    var presenterMock: WebViewPresenterMock!
    
    override func setUp() {
        super.setUp()
        // Инициализация моков
        presenterMock = WebViewPresenterMock()
        
        // Инициализация контроллера
        viewController = WebViewViewController()
        viewController.webViewPresenter = presenterMock
        
        // Принудительно вызываем загрузку View, чтобы протестировать viewDidLoad
        _ = viewController.view
    }
    
    override func tearDown() {
        viewController = nil
        presenterMock = nil
        super.tearDown()
    }
    
    func testViewDidLoadCallsPresenterViewDidLoad() {
        // Проверяем, что метод viewDidLoad у презентера вызван
        XCTAssertTrue(presenterMock.isViewDidLoadCalled)
    }
    
    
    func testPresenterCallsLoadRequest() {
        //given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.webView = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewController.loadRequestCalled)
    }
    
    
    func testProgressVisibleWhenLessThenOne() {
        
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1
        
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        XCTAssertTrue(shouldHideProgress)
        
    }
    
    func testAuthHelperAuthURL() {
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        let encodedAccessScope = configuration.accessScope.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = authHelper.authURL()
        
       guard let urlString = url?.absoluteString else {
            XCTFail("Auth URL is nil")
           return
        }
        
        XCTAssertTrue(urlString.contains(configuration.authorizeURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(encodedAccessScope ?? ""))
        
    }
    
    func testCodeFromURL() {
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        var URLComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")
        URLComponents?.queryItems = [URLQueryItem(name: "code", value: "test code")]
        guard let url = URLComponents?.url else {
            XCTFail("URL is nil")
            return
        }
        
        let code = authHelper.code(from: url)
        
        XCTAssertEqual(code, "test code", "Extracted code does not match")
        
    }
    
}

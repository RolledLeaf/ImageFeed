import Foundation
public protocol WebViewPresenterProtocol {
    var webView: WebViewViewControllerProtocol? { get set}
    func viewDidLoad()
    func loadAuthView()
    func didUpdateProgressValue(_ newValue: Double)
}

final class WebViewPresenter: WebViewPresenterProtocol {
    weak var webView: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        loadAuthView()
        
    }
    func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("Loading error")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            print("Loading error")
            return
        }
        
        let request = URLRequest(url: url)
        webView?.load(request: request)
        print("Authorization URL: \(url.absoluteString)")
        
        didUpdateProgressValue(0)

        webView?.load(request: request)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        webView?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        webView?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    
}
    
    
    private enum WebViewConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    }
    
    









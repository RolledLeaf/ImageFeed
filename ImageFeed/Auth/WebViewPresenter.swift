import Foundation
public protocol WebViewPresenterProtocol {
    var webView: WebViewViewControllerProtocol? { get set}
    func viewDidLoad()
   
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
    
}

final class WebViewPresenter: WebViewPresenterProtocol {
    weak var webView: WebViewViewControllerProtocol?
    var authHelper: AuthHelperProtocol
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    func viewDidLoad() {
     
        guard let request = authHelper.authRequest() else { return }
        
        webView?.load(request: request)
        didUpdateProgressValue(0)
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from:  url)
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

    
    
    









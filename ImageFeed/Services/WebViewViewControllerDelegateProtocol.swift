
protocol WebViewViewControllerDelegate: AnyObject {
    func didReceiveAuthorizationCode(_ code: String)
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
    
}

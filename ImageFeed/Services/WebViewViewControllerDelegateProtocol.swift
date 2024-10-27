
protocol WebViewViewControllerDelegate: AnyObject {
    func didReceiveAuthorizationCode(_ code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

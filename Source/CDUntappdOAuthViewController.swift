//
//  CDUntappdOAuthViewController.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 8/9/17.
//
//  Copyright © 2016-2022 Christopher de Haan <contact@christopherdehaan.me>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Alamofire
import WebKit

class CDUntappdOAuthViewController: UIViewController {

    var oAuthClient: CDUntappdOAuthClient!
    var onAuthorization: ((Bool, Error?) -> Void)?

    private var webView: WKWebView!

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        let webView = WKWebView(frame: self.view.frame)
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        self.webView = webView

        let urlString = CDUntappdURL.oAuth + "authenticate/?client_id=" + self.oAuthClient.clientId + "&response_type=code&redirect_url=" + self.oAuthClient.redirectUrl
        let url = URL(string: urlString)
        if let url = url {
            let urlRequest = URLRequest(url: url)
            self.webView.load(urlRequest)
        }
    }
}

// MARK: - WKNavigationDelegate Methods

extension CDUntappdOAuthViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        let scheme = self.oAuthClient.redirectUrl + "?code="
        if let url = navigationAction.request.url?.absoluteString,
            url.contains(scheme) {

            decisionHandler(.cancel)
            var authorizationCode = ""
            if let range = url.range(of: "?code=") {
                let code = String(url[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
                authorizationCode = code
            }
            self.oAuthClient.authorize(withCode: authorizationCode,
                                       completion: { (successful, error) in

                if let error = error {
                    self.onAuthorization?(false, error)
                }

                if let successful = successful,
                    successful == true {
                    self.onAuthorization?(true, nil)
                } else {
                    self.onAuthorization?(false, nil)
                }
            })
        }

        decisionHandler(.allow)
    }
}

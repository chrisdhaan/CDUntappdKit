//
//  CDUntappdAuthenticationViewController.swift
//  CDUntappdKit
//
//  Created by Chris De Haan on 8/9/17.
//
//  Copyright (c) 2016-2017 Christopher de Haan <contact@christopherdehaan.me>
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
import AlamofireObjectMapper
import WebKit

class CDUntappdOAuthViewController: UIViewController {

    fileprivate var code: String?
    
    var clientId: String!
    var clientSecret: String!
    var redirectUrl: String!
    var oAuthCredential: CDUntappdOAuthCredential? = nil
    var onAuthorization: ((Bool, Error?) -> ())? = nil
    
    private var webView: WKWebView!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webView = WKWebView(frame: self.view.frame)
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        self.webView = webView
        
        let urlString = CDUntappdURL.oAuth + "authenticate/?client_id=" + self.clientId + "&response_type=code&redirect_url=" + self.redirectUrl
        let url = URL(string: urlString)
        if let url = url {
            let urlRequest = URLRequest(url: url)
            self.webView.load(urlRequest)
        }
    }
    
    // MARK: - Authorization Methods
    
    fileprivate func authorize() {
        if let code = self.code {
            let params: Parameters = ["client_id": self.clientId,
                                      "client_secret": self.clientSecret,
                                      "response_type": "code",
                                      "redirect_url": self.redirectUrl,
                                      "code": code]
            Alamofire.request(CDUntappdOAuthRouter.authorize(parameters: params)).responseObject { (response: DataResponse<CDUntappdOAuthCredential>) in
                switch response.result {
                case .success(let oAuthCredential):
                    self.oAuthCredential = oAuthCredential
                    self.onAuthorization?(true, nil)
                case .failure(let error):
                    print("authorize() failure: ", error.localizedDescription)
                    self.onAuthorization?(false, error)
                }
            }
        } else {
            self.onAuthorization?(false, nil)
        }
    }
}

// MARK: - WKNavigationDelegate Methods

extension CDUntappdOAuthViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let scheme = self.redirectUrl + "?code="
        if let url = navigationAction.request.url?.absoluteString,
            url.contains(scheme) {
            decisionHandler(.cancel)
            if let range = url.range(of: "?code=") {
                let code = url.substring(from: range.upperBound).trimmingCharacters(in: .whitespacesAndNewlines)
                self.code = code
            }
            self.authorize()
        }
        
        decisionHandler(.allow)
    }
}

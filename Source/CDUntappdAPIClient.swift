//
//  CDUntappdAPIClient.swift
//  CDUntappdKit
//
//  Created by Chris De Haan on 8/4/17.
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

public class CDUntappdAPIClient: NSObject {
    
    private let clientId: String!
    private let clientSecret: String!
    private let redirectUrl: String!
    private var oAuthViewController: CDUntappdOAuthViewController? = nil
    
    // MARK: - Initializers
    
    ///
    /// Initializes a new CDUntappdAPIClient object.
    ///
    /// - parameters:
    ///   - clientId: (**Required**) A unique identifier for the Untappd application used for authenticating with the Untappd API.
    ///   - clientSecret: (**Required**) A unique key for the Untappd application used for authenticating with the Untappd API. **Do not share this key**.
    ///   - redirectUrl: (**Required**) A url to redirect the Untappd application to during the authentication process.
    ///
    /// - returns: Void
    ///
    public init(clientId: String!,
                clientSecret: String!,
                redirectUrl: String!) {
        assert((clientId != nil && clientId != "") &&
            (clientSecret != nil && clientSecret != "") &&
            (redirectUrl != nil && redirectUrl != ""), "A clientId, clientSecret, and redirectUrl are required to query the Untappd Developers API oauth endpoint.")
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectUrl = redirectUrl
        super.init()
        self.authenticate()
    }
    
    // MARK: - Authentication Methods
    
    ///
    /// Attempts to authenticate the Untappd application credentials with the Untappd API.
    ///
    /// - returns: Void
    ///
    public func authenticate() {
        if let tvc = UIApplication.topViewController(),
            tvc.parent as? UINavigationController == nil {
            let oAuthStoryboard = UIStoryboard(name: CDUntappdStoryboardIdentifier.oAuth,
                                               bundle: Bundle(identifier: CDUntappdKitBundleIdentifier))
            let oAuthNavigationController = oAuthStoryboard.instantiateViewController(withIdentifier: CDUntappdNavigationControllerIdentifier.oAuth) as! UINavigationController
            if let oAuthViewController = oAuthNavigationController.topViewController as? CDUntappdOAuthViewController {
                oAuthViewController.clientId = self.clientId
                oAuthViewController.clientSecret = self.clientSecret
                oAuthViewController.redirectUrl = self.redirectUrl
                oAuthViewController.onAuthorization = { [weak self] (successful, error) in
                    
                    if let error = error {
                        print("authorize() failure: ", error.localizedDescription)
                    }
                    self?.oAuthViewController?.dismiss(animated: true, completion: nil)
                }
                self.oAuthViewController = oAuthViewController
            }
            tvc.present(oAuthNavigationController, animated: true, completion: nil)
        }
    }
    
    ///
    /// Determines whether or not the Untappd application has successfully authorized with the Untappd API.
    ///
    /// - returns: Bool
    ///
    public func isAuthorized() -> Bool {
        if let _ = self.oAuthViewController?.oAuthCredential?.accessToken {
            return true
        } else {
            return false
        }
    }
}

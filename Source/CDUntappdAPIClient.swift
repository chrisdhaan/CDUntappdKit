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
    
    private let oAuthClient: CDUntappdOAuthClient!
    
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
        self.oAuthClient = CDUntappdOAuthClient(clientId: clientId,
                                                clientSecret: clientSecret,
                                                redirectUrl: redirectUrl)
        super.init()
    }
    
    // MARK: - Authentication Methods
    
    ///
    /// Attempts to authenticate the Untappd application credentials with the Untappd API if the Untappd application has not already authenticated.
    ///
    /// - returns: Void
    ///
    public func authenticate() {
        if let tvc = UIApplication.topViewController(),
            tvc.parent as? UINavigationController == nil,
            self.isAuthenticated() == false {
            
            let oAuthStoryboard = UIStoryboard(name: CDUntappdStoryboardIdentifier.oAuth,
                                               bundle: Bundle(identifier: CDUntappdKitBundleIdentifier))
            let oAuthNavigationController = oAuthStoryboard.instantiateViewController(withIdentifier: CDUntappdNavigationControllerIdentifier.oAuth) as! UINavigationController
            if let oAuthViewController = oAuthNavigationController.topViewController as? CDUntappdOAuthViewController {
                oAuthViewController.oAuthClient = self.oAuthClient
                oAuthViewController.onAuthorization = { (successful, error) in
                    
                    if let error = error {
                        print("authorize() failure: ", error.localizedDescription)
                    }
                    UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
                }
            }
            tvc.present(oAuthNavigationController, animated: true, completion: nil)
        }
    }
    
    ///
    /// Determines whether or not the Untappd application has successfully authenticated with the Untappd API.
    ///
    /// - returns: Bool
    ///
    public func isAuthenticated() -> Bool {
        return self.oAuthClient.isAuthorized()
    }
    
    ///
    /// Removes the Untappd API authentication credentials.
    ///
    /// - returns: Void
    ///
    public func unauthenticate() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: CDUntappdDefaults.accessToken)
        userDefaults.synchronize()
    }
}

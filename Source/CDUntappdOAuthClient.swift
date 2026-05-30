//
//  CDUntappdOAuthClient.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 8/15/17.
//
//  Copyright © 2016-2026 Christopher de Haan <contact@christopherdehaan.me>
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

#if !os(OSX)
    import UIKit
#else
    import Foundation
#endif

import Alamofire
import os.log

private let logger = Logger(subsystem: CDUntappdKitBundleIdentifier, category: "OAuthClient")

/// Handles OAuth 2.0 authentication with the Untappd API.
///
/// Manages access tokens stored in UserDefaults and adds them to API requests.
public class CDUntappdOAuthClient: NSObject, @unchecked Sendable {

    /// Your Untappd application client ID.
    public let clientId: String!
    /// Your Untappd application client secret. Do not share this value.
    public let clientSecret: String!
    /// The OAuth redirect URL registered with your Untappd application.
    public let redirectUrl: String!

    // MARK: - Initializers

    /// Creates an OAuth client for Untappd API authentication.
    /// - Parameters:
    ///   - clientId: Your Untappd application client ID.
    ///   - clientSecret: Your Untappd application client secret.
    ///   - redirectUrl: The OAuth redirect URL registered with your application.
    public init(clientId: String!,
                clientSecret: String!,
                redirectUrl: String!) {
        assert((clientId != nil && clientId != "") &&
            (clientSecret != nil && clientSecret != "") &&
            (redirectUrl != nil && redirectUrl != ""),
            "A clientId, clientSecret, and redirectUrl are required to query the Untappdd Developers API oauth endpoint.")
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectUrl = redirectUrl
    }

    // MARK: - Authorization Methods

    /// Exchanges an OAuth authorization code for an access token.
    ///
    /// - Parameters:
    ///   - code: The authorization code received from the OAuth provider.
    ///   - completion: A closure called with the result. Passes `true` and `nil` on success, `false` and an error on failure.
    public func authorize(withCode code: String!, completion: @escaping (Bool?, (any Error)?) -> Void) {
        if let clientId = self.clientId,
           let clientSecret = self.clientSecret,
           let redirectUrl = self.redirectUrl,
           let code,
           code != "" {
            let params: Parameters = ["client_id": clientId,
                                      "client_secret": clientSecret,
                                      "response_type": "code",
                                      "redirect_url": redirectUrl,
                                      "code": code]
            Alamofire.Session()
                .request(CDUntappdOAuthRouter.authorize(parameters: params))
                .responseDecodable { (response: DataResponse<CDUntappdOAuthCredential, AFError>) in
                    switch response.result {
                    case let .success(oAuthCredential):
                        let defaults = UserDefaults.standard
                        // Save access token
                        defaults.set(oAuthCredential.accessToken, forKey: CDUntappdDefaults.accessToken)
                        defaults.synchronize()
                        completion(true, nil)
                    case let .failure(error):
                        logger.error("OAuth authorization failed: \(error.localizedDescription, privacy: .public)")
                        completion(false, error)
                    }
                }
        } else {
            completion(false, nil)
        }
    }

    /// Checks if an access token is stored.
    /// - Returns: `true` if an access token exists in UserDefaults.
    public func isAuthorized() -> Bool {
        let defaults = UserDefaults.standard
        if defaults.string(forKey: CDUntappdDefaults.accessToken) != nil {
            return true
        } else {
            return false
        }
    }

    /// Returns the stored access token.
    /// - Returns: The access token string, or `nil` if no token is stored.
    public func accessToken() -> String? {
        let defaults = UserDefaults.standard
        if let accessToken = defaults.string(forKey: CDUntappdDefaults.accessToken) {
            return accessToken
        } else {
            return nil
        }
    }

    /// Adds authentication tokens to API request parameters.
    ///
    /// If an access token is available, adds it with key `access_token`.
    /// Otherwise, adds client ID and secret with keys `client_id` and `client_secret`.
    /// - Parameter parameters: The parameters dictionary to modify.
    /// - Returns: The updated parameters dictionary.
    public func addTokens(toParameters parameters: Parameters) -> Parameters {
        var params = parameters

        if let accessToken = self.accessToken() {
            params["access_token"] = accessToken
        } else {
            params["client_id"] = self.clientId
            params["client_secret"] = self.clientSecret
        }

        return params
    }
}
